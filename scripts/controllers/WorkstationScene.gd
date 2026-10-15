class_name WorkstationScene
extends Node3D

## WorkstationScene
## Assembles the cozy late-night 3D workbench level, task lamp, target repairable device
## (Vintage Recorder for Chapter 1, Vintage Fan for Chapter 2), 3D tray, 3D screwdriver, and UI overlay.

var controller: WorkstationController
var repairable_device: RepairableObject
var fan: ProceduralFan:
	get:
		return repairable_device as ProceduralFan
var tray_3d: ProceduralTray3D
var screwdriver_3d: ProceduralScrewdriver3D
var ui_overlay: UI_Overlay
var task_lamp: SpotLight3D
var lamp_bulb_mesh: MeshInstance3D

func _ready() -> void:
	_setup_3d_environment()
	_setup_3d_tools()
	_setup_repairable_device()
	_setup_controller()
	_setup_ui_overlay()

func _setup_3d_environment() -> void:
	# 1. Wooden Workbench Desk Surface (Dark Teak)
	var desk: MeshInstance3D = MeshInstance3D.new()
	var desk_box: BoxMesh = BoxMesh.new()
	desk_box.size = Vector3(2.6, 0.08, 1.8)
	desk.mesh = desk_box
	
	var desk_mat: StandardMaterial3D = StandardMaterial3D.new()
	desk_mat.albedo_color = Color("2c1f17") # Rich warm dark teak wood
	desk_mat.roughness = 0.65
	desk_mat.metallic = 0.04
	desk.material_override = desk_mat
	desk.position = Vector3(0, -0.34, 0)
	add_child(desk)

	# 2. Repair Cutting Mat on the desk surface
	var mat_mesh: MeshInstance3D = MeshInstance3D.new()
	var mat_box: BoxMesh = BoxMesh.new()
	mat_box.size = Vector3(1.35, 0.004, 0.92)
	mat_mesh.mesh = mat_box
	
	var cutting_mat_mat: StandardMaterial3D = StandardMaterial3D.new()
	cutting_mat_mat.albedo_color = Color("1e2528") # Dark slate antistatic cutting mat
	cutting_mat_mat.roughness = 0.85
	mat_mesh.material_override = cutting_mat_mat
	mat_mesh.position = Vector3(-0.06, -0.298, 0.04)
	add_child(mat_mesh)

	# Cutting mat gold border accent
	var mat_border: MeshInstance3D = MeshInstance3D.new()
	var border_box: BoxMesh = BoxMesh.new()
	border_box.size = Vector3(1.37, 0.003, 0.94)
	mat_border.mesh = border_box
	var border_mat: StandardMaterial3D = StandardMaterial3D.new()
	border_mat.albedo_color = Color("5c4a22") # Muted brass border
	border_mat.roughness = 0.5
	border_mat.metallic = 0.6
	mat_border.material_override = border_mat
	mat_border.position = Vector3(-0.06, -0.299, 0.04)
	add_child(mat_border)

	# 3. Vintage Gooseneck Task Lamp (Cozy 3200K warm lighting)
	var lamp_root: Node3D = Node3D.new()
	lamp_root.name = "VintageTaskLamp"
	lamp_root.position = Vector3(0.58, -0.30, -0.12)
	add_child(lamp_root)

	var lamp_mat_iron: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat_iron.albedo_color = Color("22262c")
	lamp_mat_iron.metallic = 0.5
	lamp_mat_iron.roughness = 0.55

	var lamp_mat_brass: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat_brass.albedo_color = Color("cda844")
	lamp_mat_brass.metallic = 0.85
	lamp_mat_brass.roughness = 0.28

	# Lamp base
	var l_base: MeshInstance3D = MeshInstance3D.new()
	var lb_cyl: CylinderMesh = CylinderMesh.new()
	lb_cyl.top_radius = 0.10
	lb_cyl.bottom_radius = 0.12
	lb_cyl.height = 0.03
	l_base.mesh = lb_cyl
	l_base.material_override = lamp_mat_iron
	l_base.position = Vector3(0, 0.015, 0)
	lamp_root.add_child(l_base)

	# Lamp curved neck
	var l_arm: MeshInstance3D = MeshInstance3D.new()
	var la_cyl: CylinderMesh = CylinderMesh.new()
	la_cyl.top_radius = 0.018
	la_cyl.bottom_radius = 0.022
	la_cyl.height = 0.65
	l_arm.mesh = la_cyl
	l_arm.material_override = lamp_mat_brass
	l_arm.position = Vector3(-0.08, 0.32, 0.08)
	l_arm.rotation.z = deg_to_rad(20.0)
	l_arm.rotation.x = deg_to_rad(-12.0)
	lamp_root.add_child(l_arm)

	# Lamp shade
	var l_shade: MeshInstance3D = MeshInstance3D.new()
	var ls_cyl: CylinderMesh = CylinderMesh.new()
	ls_cyl.top_radius = 0.06
	ls_cyl.bottom_radius = 0.14
	ls_cyl.height = 0.16
	l_shade.mesh = ls_cyl
	l_shade.material_override = lamp_mat_iron
	l_shade.position = Vector3(-0.18, 0.62, 0.16)
	l_shade.rotation.z = deg_to_rad(45.0)
	l_shade.rotation.x = deg_to_rad(-25.0)
	lamp_root.add_child(l_shade)

	# Glowing incandescent bulb
	lamp_bulb_mesh = MeshInstance3D.new()
	var bulb_sph: SphereMesh = SphereMesh.new()
	bulb_sph.radius = 0.035
	bulb_sph.height = 0.07
	lamp_bulb_mesh.mesh = bulb_sph
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color("fff3e0")
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color("ffe0b2")
	bulb_mat.emission_energy_multiplier = 3.5
	lamp_bulb_mesh.material_override = bulb_mat
	lamp_bulb_mesh.position = l_shade.position + Vector3(-0.02, -0.04, 0.02)
	lamp_root.add_child(lamp_bulb_mesh)

	# Primary SpotLight3D casting focused warm beam onto the workbench
	task_lamp = SpotLight3D.new()
	task_lamp.name = "TaskLamp"
	task_lamp.light_color = Color("ffe0b2") # Warm 3200K incandescent
	task_lamp.light_energy = 3.8
	task_lamp.spot_range = 3.5
	task_lamp.spot_angle = 52.0
	task_lamp.spot_attenuation = 1.2
	task_lamp.shadow_enabled = true
	task_lamp.position = lamp_root.position + l_shade.position
	add_child(task_lamp)
	task_lamp.look_at(Vector3(0.04, 0.05, 0.05), Vector3.UP)

	# 4. Cozy Ceramic Coffee Mug on Table
	var mug_root: Node3D = Node3D.new()
	mug_root.name = "CoffeeMug"
	mug_root.position = Vector3(0.48, -0.30, 0.32)
	add_child(mug_root)

	var mug_mesh: MeshInstance3D = MeshInstance3D.new()
	var mug_cyl: CylinderMesh = CylinderMesh.new()
	mug_cyl.top_radius = 0.042
	mug_cyl.bottom_radius = 0.038
	mug_cyl.height = 0.09
	mug_mesh.mesh = mug_cyl
	var mug_mat: StandardMaterial3D = StandardMaterial3D.new()
	mug_mat.albedo_color = Color("ece8df") # Off-white glazed ceramic
	mug_mat.roughness = 0.35
	mug_mesh.material_override = mug_mat
	mug_mesh.position = Vector3(0, 0.045, 0)
	mug_root.add_child(mug_mesh)

	var coffee_mesh: MeshInstance3D = MeshInstance3D.new()
	var cof_cyl: CylinderMesh = CylinderMesh.new()
	cof_cyl.top_radius = 0.038
	cof_cyl.bottom_radius = 0.038
	cof_cyl.height = 0.005
	coffee_mesh.mesh = cof_cyl
	var coffee_mat: StandardMaterial3D = StandardMaterial3D.new()
	coffee_mat.albedo_color = Color("1b130e") # Dark roast coffee
	coffee_mat.roughness = 0.2
	coffee_mesh.material_override = coffee_mat
	coffee_mesh.position = Vector3(0, 0.082, 0)
	mug_root.add_child(coffee_mesh)

	# 5. Soft Ambient Midnight Fill Light (Moon/City Window Reflection)
	var fill_light: DirectionalLight3D = DirectionalLight3D.new()
	fill_light.light_color = Color("242d42")
	fill_light.light_energy = 0.75
	fill_light.rotation_degrees = Vector3(-45, -35, 0)
	add_child(fill_light)

func _setup_3d_tools() -> void:
	# 3D Parts Organizer Tray resting on desk mat to the left of the device
	tray_3d = ProceduralTray3D.new()
	tray_3d.name = "Tray3D"
	tray_3d.position = Vector3(-0.48, -0.298, -0.05)
	add_child(tray_3d)

	# 3D Screwdriver resting on desk mat to the right of the device
	screwdriver_3d = ProceduralScrewdriver3D.new()
	screwdriver_3d.name = "Screwdriver3D"
	screwdriver_3d.position = Vector3(0.38, -0.288, 0.08)
	add_child(screwdriver_3d)

func _setup_repairable_device() -> void:
	var target_scene: PackedScene = null
	if GameManager.active_chapter and GameManager.active_chapter.target_model_scene:
		target_scene = GameManager.active_chapter.target_model_scene
	else:
		# Fallback to Chapter 1 Recorder
		target_scene = load("res://scenes/objects/VintageRecorder.tscn")
		
	var instance: Node = target_scene.instantiate()
	repairable_device = instance as RepairableObject
	repairable_device.position = Vector3(0.04, -0.30, 0.0)
	add_child(repairable_device)
	
	repairable_device.part_repaired.connect(func(part_id: String):
		if ui_overlay:
			ui_overlay.show_toast("Cleaned & Restored %s!" % part_id, false)
	)
	
	repairable_device.operational_state_changed.connect(func(is_running: bool):
		if is_running:
			if ui_overlay:
				var dev_name: String = repairable_device.object_name
				ui_overlay.show_toast("✨ %s is running smoothly!" % dev_name, false)
			# Lamp warmth pulse
			var tween: Tween = create_tween()
			tween.tween_property(task_lamp, "light_energy", 4.3, 0.25)
			tween.tween_property(task_lamp, "light_energy", 3.8, 0.5)
	)

func _setup_controller() -> void:
	controller = WorkstationController.new()
	controller.name = "WorkstationController"
	controller.repairable_object = repairable_device
	
	# Orbit Pivot & Camera setup
	var pivot: Node3D = Node3D.new()
	pivot.name = "OrbitPivot"
	# Centered between machine and desk tools
	pivot.position = Vector3(-0.04, 0.12, 0.04)
	add_child(pivot)
	controller.orbit_pivot = pivot
	
	var cam: Camera3D = Camera3D.new()
	cam.name = "Camera3D"
	cam.fov = 46.0
	pivot.add_child(cam)
	controller.camera = cam
	
	controller.notification_requested.connect(func(msg: String, is_warn: bool):
		if ui_overlay:
			ui_overlay.show_toast(msg, is_warn)
	)
	
	add_child(controller)

func _setup_ui_overlay() -> void:
	ui_overlay = UI_Overlay.new()
	ui_overlay.name = "UI_Overlay"
	ui_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_overlay.controller = controller
	
	ui_overlay.story_button_pressed.connect(func():
		GameManager.change_state(GameManager.State.STORY_READER)
	)
	
	ui_overlay.back_to_chapters_pressed.connect(func():
		GameManager.change_state(GameManager.State.CHAPTER_SELECT)
	)
	
	add_child(ui_overlay)
