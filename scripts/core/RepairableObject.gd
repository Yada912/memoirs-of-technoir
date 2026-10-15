class_name RepairableObject
extends Node3D

## RepairableObject
## Base class for all 3D repairable machines in Memoirs of Technoir.
## Coordinates the PartNode dependency graph, repair verification, and operational test run state.

signal part_state_changed(part_id: String, is_detached: bool)
signal part_repaired(part_id: String)
signal all_parts_repaired()
signal test_run_activated(success: bool)
signal operational_state_changed(is_running: bool)

@export var object_name: String = "Machine"
@export var is_operational: bool = false

var parts_by_id: Dictionary = {}
var registered_parts: Array[PartNode] = []

func _ready() -> void:
	_discover_and_register_parts(self)

func _discover_and_register_parts(node: Node) -> void:
	if node is PartNode:
		var p: PartNode = node as PartNode
		if p.part_id.is_empty():
			p.part_id = p.name
		parts_by_id[p.part_id] = p
		registered_parts.append(p)
		p.detached.connect(_on_part_detached)
		p.attached.connect(_on_part_attached)
		p.repaired.connect(_on_part_repaired)
		
	for child in node.get_children():
		_discover_and_register_parts(child)

func get_part(id: String) -> PartNode:
	return parts_by_id.get(id, null)

## Validates whether a part can be detached according to dependencies and active tool
func can_detach(part: PartNode) -> Dictionary:
	if not part:
		return {"allowed": false, "reason": "invalid_part"}
		
	if part.is_detached:
		return {"allowed": false, "reason": "already_detached"}
		
	# Check physical prerequisite dependencies
	var blocking_parts: Array[String] = []
	for prereq_id in part.prerequisite_part_ids:
		var prereq: PartNode = get_part(prereq_id)
		if prereq and not prereq.is_detached:
			blocking_parts.append(prereq.display_name)
			
	if not blocking_parts.is_empty():
		return {
			"allowed": false,
			"reason": "prerequisites_unmet",
			"blocking_names": blocking_parts,
			"message": "Blocked! Remove %s first." % [", ".join(blocking_parts)]
		}
		
	# Check active tool requirement
	var active_tool: String = ToolBeltManager.get_active_tool()
	if part.required_tool != "none" and part.required_tool != active_tool:
		var req_name: String = ToolBeltManager.TOOL_METADATA.get(part.required_tool, {}).get("name", part.required_tool)
		return {
			"allowed": false,
			"reason": "tool_mismatch",
			"required_tool": part.required_tool,
			"message": "Requires tool: %s" % req_name
		}
		
	return {"allowed": true}

## Validates whether a part can be attached back from the tray
func can_attach(part: PartNode) -> Dictionary:
	if not part or not part.is_detached:
		return {"allowed": false, "reason": "not_detached"}
		
	# A part can only be reattached if parts that depend on it are NOT already attached
	for other_id in parts_by_id.keys():
		var other: PartNode = parts_by_id[other_id]
		if other.prerequisite_part_ids.has(part.part_id) and not other.is_detached:
			return {
				"allowed": false,
				"reason": "dependent_already_present",
				"message": "Cannot reattach while %s is in the way." % other.display_name
			}
			
	return {"allowed": true}

func is_fully_repaired() -> bool:
	for p in registered_parts:
		if p.is_damaged and not p.is_repaired:
			return false
	return true

func is_fully_reassembled() -> bool:
	for p in registered_parts:
		if p.is_detached:
			return false
	return true

## Triggers the operational Test Run of the repaired machine
func trigger_test_run() -> bool:
	if not is_fully_reassembled():
		AudioManager.play_blocked()
		test_run_activated.emit(false)
		return false
		
	if not is_fully_repaired():
		AudioManager.play_blocked()
		test_run_activated.emit(false)
		return false
		
	is_operational = true
	AudioManager.play_success()
	AudioManager.start_motor_hum()
	on_test_run_started()
	test_run_activated.emit(true)
	operational_state_changed.emit(true)
	return true

func stop_test_run() -> void:
	is_operational = false
	AudioManager.stop_motor_hum()
	on_test_run_stopped()
	operational_state_changed.emit(false)

## Virtual hooks for device-specific behavior (e.g. fan blade spinning)
func on_test_run_started() -> void:
	pass

func on_test_run_stopped() -> void:
	pass

func _on_part_detached(part: PartNode) -> void:
	part_state_changed.emit(part.part_id, true)

func _on_part_attached(part: PartNode) -> void:
	part_state_changed.emit(part.part_id, false)

func _on_part_repaired(part: PartNode) -> void:
	part_repaired.emit(part.part_id)
	if is_fully_repaired():
		all_parts_repaired.emit()
