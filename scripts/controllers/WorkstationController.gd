class_name WorkstationController
extends Node3D

## WorkstationController
## Handles multi-touch orbit, fluid camera pan, pinch-zoom, camera mode toggle,
## 3D component outline/selection, and physical part disassembly to table/tray.

signal part_hovered(part: PartNode)
signal part_unhovered(part: PartNode)
signal part_selected(part: PartNode)
signal notification_requested(text: String, is_warning: bool)
signal camera_mode_changed(mode_name: String)

enum CameraMode { ORBIT, PAN }

@export_group("References")
@export var camera: Camera3D
@export var orbit_pivot: Node3D
@export var repairable_object: RepairableObject

@export_group("Orbit, Pan & Zoom Settings")
@export var orbit_sensitivity: float = 0.0055
@export var pan_sensitivity: float = 0.0022
@export var zoom_sensitivity: float = 0.14
@export var min_zoom_distance: float = 0.70
@export var max_zoom_distance: float = 2.4
@export var min_pitch_deg: float = -60.0
@export var max_pitch_deg: float = 75.0

# Camera orbit & pan state
var camera_mode: CameraMode = CameraMode.ORBIT
var _default_yaw: float = deg_to_rad(25.0)
var _default_pitch: float = deg_to_rad(14.0)
var _default_focal_point: Vector3 = Vector3(0.04, 0.16, 0.0)
var _default_distance: float = 1.38

var _yaw: float = deg_to_rad(25.0)
var _pitch: float = deg_to_rad(14.0)
var _target_focal_point: Vector3 = Vector3(0.04, 0.16, 0.0)
var _current_focal_point: Vector3 = Vector3(0.04, 0.16, 0.0)
var _current_distance: float = 1.38
var _target_distance: float = 1.38

# Touch gesture state
var _touch_points: Dictionary = {} # index -> Vector2
var _touch_down_positions: Dictionary = {} # index -> Vector2
var _current_pinch_dist: float = 0.0
var _last_pinch_center: Vector2 = Vector2.ZERO
var _is_orbiting: bool = false
var _is_panning: bool = false
var _is_mouse_dragging: bool = false
var _mouse_down_pos: Vector2 = Vector2.ZERO
var _drag_dist_accum: float = 0.0
const TAP_THRESHOLD: float = 16.0

var _currently_selected_part: PartNode = null
var _hovered_part: PartNode = null

func _ready() -> void:
	if not orbit_pivot:
		orbit_pivot = Node3D.new()
		orbit_pivot.name = "OrbitPivot"
		add_child(orbit_pivot)
		
	if not camera:
		camera = Camera3D.new()
		camera.name = "WorkstationCamera"
		orbit_pivot.add_child(camera)
		
	_update_camera_transform(true)

func _process(delta: float) -> void:
	_update_camera_transform(false, delta)

func toggle_camera_mode() -> CameraMode:
	if camera_mode == CameraMode.ORBIT:
		camera_mode = CameraMode.PAN
		camera_mode_changed.emit("PAN")
	else:
		camera_mode = CameraMode.ORBIT
		camera_mode_changed.emit("ORBIT")
	return camera_mode

func reset_camera() -> void:
	_pitch = _default_pitch
	_yaw = _default_yaw
	_target_distance = _default_distance
	_target_focal_point = _default_focal_point

func _update_camera_transform(instant: bool, delta: float = 0.0) -> void:
	if not camera or not orbit_pivot:
		return
		
	if instant:
		_current_distance = _target_distance
		_current_focal_point = _target_focal_point
		orbit_pivot.position = _current_focal_point
		orbit_pivot.rotation.x = _pitch
		orbit_pivot.rotation.y = _yaw
	else:
		_current_distance = lerpf(_current_distance, _target_distance, delta * 12.0)
		_current_focal_point = _current_focal_point.lerp(_target_focal_point, delta * 12.0)
		orbit_pivot.position = _current_focal_point
		orbit_pivot.rotation.x = lerp_angle(orbit_pivot.rotation.x, _pitch, delta * 16.0)
		orbit_pivot.rotation.y = lerp_angle(orbit_pivot.rotation.y, _yaw, delta * 16.0)
		
	camera.position = Vector3(0, 0, _current_distance)

func _unhandled_input(event: InputEvent) -> void:
	# 1. Multi-Touch handling (Mobile/Android)
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
			_touch_down_positions[event.index] = event.position
			if _touch_points.size() == 1:
				_is_orbiting = (camera_mode == CameraMode.ORBIT)
				_is_panning = (camera_mode == CameraMode.PAN)
				_drag_dist_accum = 0.0
			elif _touch_points.size() == 2:
				_is_orbiting = false
				_is_panning = true
				var pts = _touch_points.values()
				_current_pinch_dist = pts[0].distance_to(pts[1])
				_last_pinch_center = (pts[0] + pts[1]) * 0.5
		else:
			var down_pos: Vector2 = _touch_down_positions.get(event.index, event.position)
			var move_dist: float = (event.position - down_pos).length()
			_touch_points.erase(event.index)
			_touch_down_positions.erase(event.index)
			
			if _touch_points.size() == 1:
				_is_orbiting = (camera_mode == CameraMode.ORBIT)
				_is_panning = (camera_mode == CameraMode.PAN)
			else:
				_is_orbiting = false
				_is_panning = false
				if move_dist < TAP_THRESHOLD and _drag_dist_accum < TAP_THRESHOLD:
					_handle_tap_at(event.position)
					
	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		if _touch_points.size() >= 2:
			# 2-Finger Pinch Zoom + Pan
			var pts = _touch_points.values()
			var new_dist: float = pts[0].distance_to(pts[1])
			var pinch_diff: float = new_dist - _current_pinch_dist
			_target_distance = clampf(_target_distance - (pinch_diff * 0.003), min_zoom_distance, max_zoom_distance)
			_current_pinch_dist = new_dist
			
			var new_center: Vector2 = (pts[0] + pts[1]) * 0.5
			var pan_delta: Vector2 = new_center - _last_pinch_center
			_apply_pan(pan_delta)
			_last_pinch_center = new_center
			_drag_dist_accum += 20.0
		elif _touch_points.size() == 1:
			var delta_pos: Vector2 = event.relative
			_drag_dist_accum += delta_pos.length()
			if camera_mode == CameraMode.PAN:
				_apply_pan(delta_pos)
			else:
				_yaw -= delta_pos.x * orbit_sensitivity
				_pitch = clampf(_pitch - delta_pos.y * orbit_sensitivity, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))

	# 2. Desktop Mouse Handling
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_mouse_dragging = true
				_mouse_down_pos = event.position
				_drag_dist_accum = 0.0
				_is_orbiting = (camera_mode == CameraMode.ORBIT)
				_is_panning = (camera_mode == CameraMode.PAN)
			else:
				_is_mouse_dragging = false
				_is_orbiting = false
				_is_panning = false
				var dist: float = (event.position - _mouse_down_pos).length()
				if dist < TAP_THRESHOLD and _drag_dist_accum < TAP_THRESHOLD:
					_handle_tap_at(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_distance = clampf(_target_distance - zoom_sensitivity, min_zoom_distance, max_zoom_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_distance = clampf(_target_distance + zoom_sensitivity, min_zoom_distance, max_zoom_distance)

	elif event is InputEventMouseMotion:
		if _is_panning or (_is_mouse_dragging and camera_mode == CameraMode.PAN):
			_drag_dist_accum += event.relative.length()
			_apply_pan(event.relative)
		elif _is_orbiting or (_is_mouse_dragging and camera_mode == CameraMode.ORBIT):
			_drag_dist_accum += event.relative.length()
			_yaw -= event.relative.x * orbit_sensitivity
			_pitch = clampf(_pitch - event.relative.y * orbit_sensitivity, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
		else:
			_handle_hover_raycast(event.position)

func _apply_pan(delta_px: Vector2) -> void:
	if not camera:
		return
	var right: Vector3 = camera.global_transform.basis.x
	var up: Vector3 = camera.global_transform.basis.y
	var move_vec: Vector3 = (-right * delta_px.x + up * delta_px.y) * pan_sensitivity * (_current_distance * 0.7)
	_target_focal_point += move_vec
	# Clamp focal point around workbench area
	_target_focal_point.x = clampf(_target_focal_point.x, -1.0, 1.0)
	_target_focal_point.y = clampf(_target_focal_point.y, -0.4, 0.8)
	_target_focal_point.z = clampf(_target_focal_point.z, -0.8, 0.8)

func _handle_hover_raycast(screen_pos: Vector2) -> void:
	var hit_part: PartNode = _raycast_part_at(screen_pos)
	if hit_part != _hovered_part:
		if _hovered_part and _hovered_part != _currently_selected_part:
			_hovered_part.set_highlight(false)
			part_unhovered.emit(_hovered_part)
		_hovered_part = hit_part
		if _hovered_part:
			_hovered_part.set_highlight(true)
			part_hovered.emit(_hovered_part)

func _handle_tap_at(screen_pos: Vector2) -> void:
	var target_node: Node = _raycast_interactable_at(screen_pos)
	
	# Case A: Tapped the 3D Screwdriver on the table
	if target_node is ProceduralScrewdriver3D:
		var sd: ProceduralScrewdriver3D = target_node as ProceduralScrewdriver3D
		sd.on_clicked()
		var is_now_screw: bool = (ToolBeltManager.get_active_tool() == ToolBeltManager.TOOL_SCREWDRIVER)
		if is_now_screw:
			notification_requested.emit("Equipped 3D Screwdriver (tap screws to loosen/tighten)", false)
		else:
			notification_requested.emit("Stored Screwdriver back on mat.", false)
		return

	# Case B: Tapped the 3D Parts Organizer Tray
	if target_node is ProceduralTray3D:
		var tray: ProceduralTray3D = target_node as ProceduralTray3D
		tray.on_clicked()
		notification_requested.emit("Parts Tray: Detached screws and plates rest here.", false)
		return

	# Case C: Tapped an interactable PartNode
	var part: PartNode = target_node as PartNode
	if not part:
		# Tapped empty space -> deselect
		if _currently_selected_part:
			_currently_selected_part.select_part(false)
			_currently_selected_part = null
		return
		
	# Select and outline the tapped part
	if _currently_selected_part and _currently_selected_part != part:
		_currently_selected_part.select_part(false)
	_currently_selected_part = part
	part.select_part(true)
	part_selected.emit(part)
	
	# Case C1: On-Machine PLAY Button (Recorder)
	if part.part_id == "PlayButton":
		_handle_play_button_tap()
		return

	# Case C2: On-Machine STOP Button (Recorder)
	if part.part_id == "StopButton":
		_handle_stop_button_tap()
		return

	# Case C3: On-Machine POWER SWITCH (Fan)
	if part.part_id == "PowerSwitch":
		_handle_power_switch_tap()
		return

	# Case C4: Tapped a DISASSEMBLED part sitting in tray/table -> Reattach to device
	if part.is_detached:
		if not repairable_object:
			return
		var attach_eval: Dictionary = repairable_object.can_attach(part)
		if attach_eval.allowed:
			part.animate_attach_from_table()
			notification_requested.emit("Reattached %s." % part.display_name, false)
		else:
			part.animate_blocked_shake()
			notification_requested.emit(attach_eval.message, true)
		return

	# Case C5: Damaged component (e.g. oxidized tape head or seized fan motor)
	if part.is_damaged and not part.is_repaired:
		var active_tool: String = ToolBeltManager.get_active_tool()
		if active_tool == "cleaner_brush":
			part.perform_repair()
			notification_requested.emit("Cleaned & Restored %s!" % part.display_name, false)
			return
		elif part.required_tool == "cleaner_brush":
			part.animate_blocked_shake()
			notification_requested.emit("Component is caked with grime. Equip Cleaning Brush!", true)
			return

	# Case C6: Assembled component -> Check tool and detach to table/tray
	if not repairable_object:
		return
	var detach_eval: Dictionary = repairable_object.can_detach(part)
	if not detach_eval.allowed:
		part.animate_blocked_shake()
		notification_requested.emit(detach_eval.message, true)
		return

	# Calculate resting spot on the workbench table or tray
	var target_table_pos: Vector3 = _get_table_slot_position(part)
	part.animate_detach_to_table(target_table_pos)
	notification_requested.emit("Detached %s." % part.display_name, false)

func _handle_play_button_tap() -> void:
	AudioManager.play_click(1.2)
	if not repairable_object:
		return
	var rec: ProceduralRecorder = repairable_object as ProceduralRecorder
	if rec:
		if rec._is_playing:
			rec.stop_test_run()
			notification_requested.emit("Playback stopped.", false)
			return
		var ok: bool = rec.trigger_test_run()
		if ok:
			notification_requested.emit("▶ Playing: Memoirs of Technoir (1979)", false)
		else:
			if not rec.is_fully_reassembled():
				notification_requested.emit("Cannot play: Reassemble cassette and chassis first!", true)
			elif not rec.is_fully_repaired():
				notification_requested.emit("Cannot play: Clean oxidized tape head with brush!", true)
	else:
		repairable_object.trigger_test_run()

func _handle_stop_button_tap() -> void:
	AudioManager.play_click(0.9)
	if repairable_object:
		repairable_object.stop_test_run()
		notification_requested.emit("⏹ Stopped.", false)

func _handle_power_switch_tap() -> void:
	AudioManager.play_click(1.2)
	var fan: ProceduralFan = repairable_object as ProceduralFan
	if not fan:
		return
		
	if fan.is_operational:
		fan.stop_test_run()
		notification_requested.emit("Motor switched off.", false)
		return
		
	var test_success: bool = fan.trigger_test_run()
	if test_success:
		notification_requested.emit("✨ Fan running! Motor spinning smoothly.", false)
	else:
		if not fan.is_fully_reassembled():
			notification_requested.emit("Cannot start: Reassemble all parts onto the fan first!", true)
		elif not fan.is_fully_repaired():
			notification_requested.emit("Cannot start: Motor bearing is still seized with grime!", true)

func _get_table_slot_position(part: PartNode) -> Vector3:
	if repairable_object and "table_slot_positions" in repairable_object:
		var slots: Dictionary = repairable_object.get("table_slot_positions")
		if slots.has(part.part_id):
			return slots[part.part_id]
	return Vector3(-0.45, -0.28, 0.05)

func _raycast_interactable_at(screen_pos: Vector2) -> Node:
	if not camera:
		return null
		
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + camera.project_ray_normal(screen_pos) * 12.0
	
	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return null
		
	var curr: Node = result.collider as Node
	while curr and curr != get_tree().root:
		if curr is PartNode or curr is ProceduralScrewdriver3D or curr is ProceduralTray3D:
			return curr
		curr = curr.get_parent()
		
	return null

func _raycast_part_at(screen_pos: Vector2) -> PartNode:
	var node: Node = _raycast_interactable_at(screen_pos)
	return node as PartNode
