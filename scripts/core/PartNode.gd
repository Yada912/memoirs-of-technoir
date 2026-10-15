class_name PartNode
extends Node3D

## PartNode (Interactable Part)
## Represents a modular physical component of a repairable device.
## Enforces physical prerequisite constraints, tool requirements, outline feedback, and table animations.

signal clicked(part_node: PartNode)
signal hovered(part_node: PartNode, is_hovering: bool)
signal detached(part_node: PartNode)
signal attached(part_node: PartNode)
signal repaired(part_node: PartNode)

@export_group("Component Configuration")
@export var part_id: String = ""
@export var display_name: String = "Component"
## IDs of parts that MUST be detached before this part can be detached.
@export var prerequisite_part_ids: Array[String] = []
## Tool required to interact with this part ("none", "screwdriver", "cleaner_brush", etc.)
@export var required_tool: String = "none"
## Target slot in the workstation organizer tray or table
@export var tray_slot_index: int = 0
@export var is_damaged: bool = false
@export var repair_description: String = "Clean grime and lubricate"

@export_group("Animation Parameters")
@export var detach_direction: Vector3 = Vector3(0, 0, 0.3)
@export var is_screw: bool = false

var is_detached: bool = false
var is_repaired: bool = false
var is_selected: bool = false
var original_transform: Transform3D

var _outline_material: ShaderMaterial
var _meshes: Array[MeshInstance3D] = []
var _collision_shape: CollisionShape3D
var _area: Area3D
var _is_animating: bool = false

func _ready() -> void:
	original_transform = transform
	if is_repaired or not is_damaged:
		is_repaired = true
	_setup_materials_and_meshes()
	_setup_interaction_area()

func _setup_materials_and_meshes() -> void:
	var shader: Shader = load("res://shaders/outline.gdshader")
	if shader:
		_outline_material = ShaderMaterial.new()
		_outline_material.shader = shader
		_outline_material.set_shader_parameter("outline_color", Color("ffd54f"))
		_outline_material.set_shader_parameter("outline_width", 5.0)
		_outline_material.set_shader_parameter("is_active", false)
	refresh_meshes()

func refresh_meshes() -> void:
	_meshes.clear()
	_find_mesh_instances(self)

func _find_mesh_instances(node: Node) -> void:
	if node is MeshInstance3D:
		_meshes.append(node)
	for child in node.get_children():
		_find_mesh_instances(child)

func get_meshes() -> Array[MeshInstance3D]:
	if _meshes.is_empty():
		refresh_meshes()
	return _meshes

func _setup_interaction_area() -> void:
	_area = get_node_or_null("Area3D") as Area3D
	if not _area:
		_area = Area3D.new()
		_area.name = "Area3D"
		_area.collision_layer = 1
		_area.collision_mask = 0
		add_child(_area)
		
	_collision_shape = _area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if not _collision_shape:
		_collision_shape = CollisionShape3D.new()
		_collision_shape.name = "CollisionShape3D"
		var box: BoxShape3D = BoxShape3D.new()
		box.size = Vector3(0.2, 0.2, 0.2)
		_collision_shape.shape = box
		_area.add_child(_collision_shape)
		
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)

func set_highlight(active: bool, color: Color = Color("ffd54f")) -> void:
	if not _outline_material:
		_setup_materials_and_meshes()
	if not _outline_material:
		return
		
	_outline_material.set_shader_parameter("is_active", active)
	_outline_material.set_shader_parameter("outline_color", color)
	_outline_material.set_shader_parameter("outline_width", 5.0)
	
	var mesh_list: Array[MeshInstance3D] = get_meshes()
	for mesh in mesh_list:
		var mat: Material = mesh.material_override
		if not mat:
			mat = mesh.get_surface_override_material(0)
		if not mat:
			mat = StandardMaterial3D.new()
			mesh.material_override = mat
			
		# Ensure material is uniquely owned by this mesh instance so others aren't affected
		if not mesh.has_meta("unique_mat"):
			mat = mat.duplicate()
			mesh.material_override = mat
			mesh.set_meta("unique_mat", true)
			
		if active:
			mat.next_pass = _outline_material
			if mat is StandardMaterial3D and not is_damaged:
				mat.emission_enabled = true
				mat.emission = color
				mat.emission_energy_multiplier = 0.25
		else:
			if mat.next_pass == _outline_material:
				mat.next_pass = null
			if mat is StandardMaterial3D and not is_damaged:
				mat.emission_enabled = false
				mat.emission_energy_multiplier = 0.0

func select_part(selected: bool) -> void:
	is_selected = selected
	set_highlight(selected)

func _on_mouse_entered() -> void:
	if not is_detached and not _is_animating and not is_selected:
		hovered.emit(self, true)
		set_highlight(true)

func _on_mouse_exited() -> void:
	if not is_selected:
		hovered.emit(self, false)
		set_highlight(false)

func _on_input_event(_camera: Camera3D, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

## Animate unscrewing/sliding and smooth arc flight down onto the workbench table
func animate_detach_to_table(target_world_pos: Vector3) -> void:
	if _is_animating or is_detached:
		return
	_is_animating = true
	select_part(false)
	
	# Step 1: Disassembly motion (unscrew or pull outward)
	if is_screw:
		AudioManager.play_ratchet(randf_range(0.95, 1.05))
		var local_out: Vector3 = transform.origin + (transform.basis * detach_direction * 0.5)
		var unscrew_tween: Tween = create_tween().set_parallel(true)
		unscrew_tween.tween_property(self, "transform:origin", local_out, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		unscrew_tween.tween_property(self, "rotation:z", rotation.z + TAU * 2.0, 0.35)
		await unscrew_tween.finished
	else:
		AudioManager.play_detach()
		var pull_out_pos: Vector3 = transform.origin + (transform.basis * detach_direction)
		var pull_tween: Tween = create_tween()
		pull_tween.tween_property(self, "transform:origin", pull_out_pos, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await pull_tween.finished
		
	# Step 2: Arc flight down onto the workbench table surface
	var arc_tween: Tween = create_tween().set_parallel(true)
	arc_tween.tween_property(self, "global_position", target_world_pos, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# Lay flat or natural rotation on the wooden surface
	if is_screw:
		# Lie horizontally or standing neatly
		arc_tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 90), 0.48)
	elif part_id == "FrontCage":
		# Resting flat on table
		arc_tween.tween_property(self, "rotation_degrees", Vector3(-85, 0, 0), 0.48)
	elif part_id == "Blades":
		# Lying flat on table
		arc_tween.tween_property(self, "rotation_degrees", Vector3(-90, 0, 0), 0.48)
		
	await arc_tween.finished
	AudioManager.play_clink(randf_range(0.95, 1.1))
	
	is_detached = true
	_is_animating = false
	detached.emit(self)

## Backwards compatibility alias
func animate_detach_to_tray(target_world_pos: Vector3) -> void:
	await animate_detach_to_table(target_world_pos)

## Animate back from table into original assembled position
func animate_attach_from_table() -> void:
	if _is_animating or not is_detached:
		return
	_is_animating = true
	select_part(false)
	AudioManager.play_clink(1.2)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "transform", original_transform, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	if is_screw:
		AudioManager.play_ratchet(1.3)
	else:
		AudioManager.play_detach()
		
	is_detached = false
	_is_animating = false
	attached.emit(self)

## Backwards compatibility alias
func animate_attach_from_tray() -> void:
	await animate_attach_from_table()

## Animate blocked feedback (spring shake when blocked)
func animate_blocked_shake() -> void:
	if _is_animating:
		return
	_is_animating = true
	AudioManager.play_blocked()
	set_highlight(true, Color("ef5350"))
	
	var base_pos: Vector3 = position
	var shake_tween: Tween = create_tween()
	var shake_axis: Vector3 = transform.basis.x * 0.02
	
	shake_tween.tween_property(self, "position", base_pos + shake_axis, 0.04)
	shake_tween.tween_property(self, "position", base_pos - shake_axis, 0.04)
	shake_tween.tween_property(self, "position", base_pos + shake_axis * 0.5, 0.04)
	shake_tween.tween_property(self, "position", base_pos, 0.04)
	
	await shake_tween.finished
	set_highlight(is_selected)
	_is_animating = false

## Clean/repair the part
func perform_repair() -> void:
	if is_repaired or not is_damaged:
		return
	_is_animating = true
	AudioManager.play_clean()
	set_highlight(true, Color("66bb6a")) # Flash emerald green
	
	for mesh in _meshes:
		var mat: StandardMaterial3D = mesh.material_override as StandardMaterial3D
		if not mat:
			mat = mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			var mat_tween: Tween = create_tween().set_parallel(true)
			mat_tween.tween_property(mat, "roughness", 0.22, 0.5)
			mat_tween.tween_property(mat, "metallic", 0.88, 0.5)
			mat_tween.tween_property(mat, "albedo_color", Color("d4af37"), 0.5) # Gleaming polished brass
				
	await get_tree().create_timer(0.5).timeout
	is_damaged = false
	is_repaired = true
	set_highlight(false)
	_is_animating = false
	repaired.emit(self)
