class_name ProceduralScrewdriver3D
extends Node3D

## ProceduralScrewdriver3D
## Tactile 3D screwdriver resting on the workbench desk.
## Tapping it directly on the table equips the Screwdriver tool.

signal clicked()

var is_equipped: bool = false
var _mesh_root: Node3D
var _mat_handle: StandardMaterial3D
var _mat_shank: StandardMaterial3D
var _mat_ferrule: StandardMaterial3D
var _idle_tween: Tween
var _outline_mat: ShaderMaterial

func _ready() -> void:
	_init_materials()
	_build_screwdriver_mesh()
	_setup_interaction_area()
	ToolBeltManager.tool_changed.connect(_on_tool_changed)
	_update_equipped_state(ToolBeltManager.get_active_tool() == ToolBeltManager.TOOL_SCREWDRIVER)

func _init_materials() -> void:
	# Translucent ruby red cellulose acetate handle
	_mat_handle = StandardMaterial3D.new()
	_mat_handle.albedo_color = Color("d32f2f")
	_mat_handle.metallic = 0.1
	_mat_handle.roughness = 0.22
	_mat_handle.clearcoat_enabled = true
	_mat_handle.clearcoat = 0.8

	# Polished chrome shank
	_mat_shank = StandardMaterial3D.new()
	_mat_shank.albedo_color = Color("c0c4cc")
	_mat_shank.metallic = 0.95
	_mat_shank.roughness = 0.15

	# Black knurled ferrule / bolster
	_mat_ferrule = StandardMaterial3D.new()
	_mat_ferrule.albedo_color = Color("1e2024")
	_mat_ferrule.metallic = 0.5
	_mat_ferrule.roughness = 0.6

	var shader: Shader = load("res://shaders/outline.gdshader")
	if shader:
		_outline_mat = ShaderMaterial.new()
		_outline_mat.shader = shader
		_outline_mat.set_shader_parameter("outline_color", Color("ffd54f"))
		_outline_mat.set_shader_parameter("outline_width", 4.0)
		_outline_mat.set_shader_parameter("is_active", false)

func _build_screwdriver_mesh() -> void:
	_mesh_root = Node3D.new()
	_mesh_root.name = "MeshRoot"
	add_child(_mesh_root)

	# Handle (Fluted octagonal grip)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var h_cyl: CylinderMesh = CylinderMesh.new()
	h_cyl.top_radius = 0.024
	h_cyl.bottom_radius = 0.021
	h_cyl.height = 0.14
	h_cyl.radial_segments = 8 # Fluted vintage look
	handle.mesh = h_cyl
	handle.material_override = _mat_handle
	handle.position = Vector3(0, 0, 0.07)
	handle.rotation.x = deg_to_rad(90.0)
	_mesh_root.add_child(handle)

	# Handle dome butt
	var butt: MeshInstance3D = MeshInstance3D.new()
	var b_sph: SphereMesh = SphereMesh.new()
	b_sph.radius = 0.023
	b_sph.height = 0.035
	butt.mesh = b_sph
	butt.material_override = _mat_handle
	butt.position = Vector3(0, 0, 0.14)
	_mesh_root.add_child(butt)

	# Ferrule / bolster
	var ferrule: MeshInstance3D = MeshInstance3D.new()
	var f_cyl: CylinderMesh = CylinderMesh.new()
	f_cyl.top_radius = 0.016
	f_cyl.bottom_radius = 0.022
	f_cyl.height = 0.025
	f_cyl.radial_segments = 16
	ferrule.mesh = f_cyl
	ferrule.material_override = _mat_ferrule
	ferrule.position = Vector3(0, 0, -0.01)
	ferrule.rotation.x = deg_to_rad(90.0)
	_mesh_root.add_child(ferrule)

	# Steel Shank / shaft
	var shank: MeshInstance3D = MeshInstance3D.new()
	var s_cyl: CylinderMesh = CylinderMesh.new()
	s_cyl.top_radius = 0.007
	s_cyl.bottom_radius = 0.007
	s_cyl.height = 0.16
	s_cyl.radial_segments = 16
	shank.mesh = s_cyl
	shank.material_override = _mat_shank
	shank.position = Vector3(0, 0, -0.10)
	shank.rotation.x = deg_to_rad(90.0)
	_mesh_root.add_child(shank)

	# Flathead magnetic tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var t_box: BoxMesh = BoxMesh.new()
	t_box.size = Vector3(0.012, 0.003, 0.022)
	tip.mesh = t_box
	tip.material_override = _mat_ferrule
	tip.position = Vector3(0, 0, -0.19)
	_mesh_root.add_child(tip)

func _setup_interaction_area() -> void:
	var area: Area3D = Area3D.new()
	area.name = "Area3D"
	area.collision_layer = 1
	area.collision_mask = 0
	add_child(area)

	var col: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.08, 0.08, 0.40)
	col.shape = box
	col.position = Vector3(0, 0.02, 0)
	area.add_child(col)

	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(func(): set_highlight(true))
	area.mouse_exited.connect(func(): if not is_equipped: set_highlight(false))

func _on_input_event(_camera: Camera3D, event: InputEvent, _pos: Vector3, _norm: Vector3, _idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_equip()

func toggle_equip() -> void:
	AudioManager.play_ratchet(1.1)
	if is_equipped:
		ToolBeltManager.equip_tool("hand")
	else:
		ToolBeltManager.equip_tool("screwdriver")
	clicked.emit()

func on_clicked() -> void:
	toggle_equip()

func _on_tool_changed(new_tool_id: String, _old: String) -> void:
	_update_equipped_state(new_tool_id == ToolBeltManager.TOOL_SCREWDRIVER)

func _update_equipped_state(equipped: bool) -> void:
	is_equipped = equipped
	set_highlight(equipped)
	
	if _idle_tween:
		_idle_tween.kill()

	if is_equipped:
		# Float slightly into ready position above the table
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(_mesh_root, "position:y", 0.035, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(_mesh_root, "rotation_degrees:x", -8.0, 0.25)
		
		# Gentle idle float
		_idle_tween = create_tween().set_loops()
		_idle_tween.tween_property(_mesh_root, "position:y", 0.045, 1.2).set_trans(Tween.TRANS_SINE)
		_idle_tween.tween_property(_mesh_root, "position:y", 0.035, 1.2).set_trans(Tween.TRANS_SINE)
	else:
		# Rest flat on table
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(_mesh_root, "position:y", 0.012, 0.2).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(_mesh_root, "rotation_degrees:x", 0.0, 0.2)

func set_highlight(active: bool) -> void:
	if not _outline_mat:
		return
	_outline_mat.set_shader_parameter("is_active", active)
	_mat_handle.next_pass = _outline_mat if active else null
	_mat_shank.next_pass = _outline_mat if active else null
