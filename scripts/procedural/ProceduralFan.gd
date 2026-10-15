class_name ProceduralFan
extends RepairableObject

## ProceduralFan
## Programmatically constructs a high-detail vintage desk fan using Godot 3D primitive nodes.
## Any disassembled parts get placed physically on the workbench table surface.
## The power switch / test run toggle is directly on the machine base.

var blades_assembly: PartNode
var indicator_light: OmniLight3D
var switch_knob_mesh: MeshInstance3D
var power_switch_part: PartNode

var _is_spinning: bool = false
var _current_spin_velocity: float = 0.0
var _target_spin_velocity: float = 38.0 # radians per sec

# Table placement coordinates for disassembled parts (world space on desk surface)
var table_slot_positions: Dictionary = {
	"Screw1": Vector3(-0.24, -0.29, 0.22),
	"Screw2": Vector3(-0.16, -0.29, 0.24),
	"Screw3": Vector3(-0.08, -0.29, 0.25),
	"Screw4": Vector3(0.00, -0.29, 0.25),
	"BladeLockNut": Vector3(0.14, -0.28, 0.22),
	"FrontCage": Vector3(-0.48, -0.28, 0.08),
	"Blades": Vector3(-0.38, -0.29, -0.16)
}

# Materials
var _mat_cast_iron: StandardMaterial3D
var _mat_chrome: StandardMaterial3D
var _mat_brass: StandardMaterial3D
var _mat_wire: StandardMaterial3D
var _mat_copper_grimy: StandardMaterial3D
var _mat_lamp_glow: StandardMaterial3D

func _ready() -> void:
	object_name = "Vintage Technoir Desk Fan"
	_init_materials()
	_build_fan_structure()
	super._ready()

func _init_materials() -> void:
	# Cast iron base & stand (dark vintage industrial finish)
	_mat_cast_iron = StandardMaterial3D.new()
	_mat_cast_iron.albedo_color = Color("282e34")
	_mat_cast_iron.metallic = 0.45
	_mat_cast_iron.roughness = 0.6

	# Chrome motor casing and rim accents
	_mat_chrome = StandardMaterial3D.new()
	_mat_chrome.albedo_color = Color("9aa1a6")
	_mat_chrome.metallic = 0.92
	_mat_chrome.roughness = 0.18

	# Vintage warm brass blades & lock nut
	_mat_brass = StandardMaterial3D.new()
	_mat_brass.albedo_color = Color("d4af37")
	_mat_brass.metallic = 0.88
	_mat_brass.roughness = 0.25

	# Wire cage steel
	_mat_wire = StandardMaterial3D.new()
	_mat_wire.albedo_color = Color("a6a8ab")
	_mat_wire.metallic = 0.85
	_mat_wire.roughness = 0.3

	# Grimy seized motor bearing (prior to cleaning)
	_mat_copper_grimy = StandardMaterial3D.new()
	_mat_copper_grimy.albedo_color = Color("382418")
	_mat_copper_grimy.metallic = 0.25
	_mat_copper_grimy.roughness = 0.9

	# Power indicator light material
	_mat_lamp_glow = StandardMaterial3D.new()
	_mat_lamp_glow.albedo_color = Color("ffb300")
	_mat_lamp_glow.emission_enabled = true
	_mat_lamp_glow.emission = Color("ffb300")
	_mat_lamp_glow.emission_energy_multiplier = 0.0

func _build_fan_structure() -> void:
	# 1. Base (Pedestal on the table)
	var base_node: Node3D = Node3D.new()
	base_node.name = "FanBase"
	add_child(base_node)
	
	# Pedestal foot
	var base_mesh: MeshInstance3D = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = 0.32
	cyl.bottom_radius = 0.38
	cyl.height = 0.08
	cyl.radial_segments = 36
	base_mesh.mesh = cyl
	base_mesh.material_override = _mat_cast_iron
	base_mesh.position = Vector3(0, 0.04, 0)
	base_node.add_child(base_mesh)

	# 2. Interactive Power Toggle Switch (Directly on the machine base!)
	power_switch_part = PartNode.new()
	power_switch_part.name = "PowerSwitch"
	power_switch_part.part_id = "PowerSwitch"
	power_switch_part.display_name = "Power / Speed Toggle Switch"
	power_switch_part.required_tool = "none"
	power_switch_part.position = Vector3(0, 0.09, 0.16)
	base_node.add_child(power_switch_part)
	
	# Switch escutcheon plate
	var plate_mesh: MeshInstance3D = MeshInstance3D.new()
	var p_box: BoxMesh = BoxMesh.new()
	p_box.size = Vector3(0.14, 0.012, 0.12)
	plate_mesh.mesh = p_box
	plate_mesh.material_override = _mat_cast_iron
	power_switch_part.add_child(plate_mesh)

	# Switch knob
	switch_knob_mesh = MeshInstance3D.new()
	var knob_cyl: CylinderMesh = CylinderMesh.new()
	knob_cyl.top_radius = 0.042
	knob_cyl.bottom_radius = 0.048
	knob_cyl.height = 0.05
	knob_cyl.radial_segments = 24
	switch_knob_mesh.mesh = knob_cyl
	switch_knob_mesh.material_override = _mat_brass
	switch_knob_mesh.position = Vector3(0, 0.025, 0)
	power_switch_part.add_child(switch_knob_mesh)
	
	# Switch notch pointer
	var pointer: MeshInstance3D = MeshInstance3D.new()
	var pt_box: BoxMesh = BoxMesh.new()
	pt_box.size = Vector3(0.012, 0.052, 0.038)
	pointer.mesh = pt_box
	pointer.material_override = _mat_cast_iron
	pointer.position = Vector3(0, 0.026, 0.02)
	power_switch_part.add_child(pointer)
	
	power_switch_part.refresh_meshes()
	_attach_box_collision(power_switch_part, Vector3(0.18, 0.14, 0.18))
	
	# Power indicator jewel beside switch
	var jewel: MeshInstance3D = MeshInstance3D.new()
	var jewel_mesh: SphereMesh = SphereMesh.new()
	jewel_mesh.radius = 0.022
	jewel_mesh.height = 0.044
	jewel.mesh = jewel_mesh
	jewel.material_override = _mat_lamp_glow
	jewel.position = Vector3(0.13, 0.085, 0.16)
	base_node.add_child(jewel)
	
	indicator_light = OmniLight3D.new()
	indicator_light.light_color = Color("ffb300")
	indicator_light.light_energy = 0.0
	indicator_light.omni_range = 0.6
	indicator_light.position = jewel.position + Vector3(0, 0.06, 0)
	base_node.add_child(indicator_light)

	# 3. Stand (Curved neck)
	var stand_mesh: MeshInstance3D = MeshInstance3D.new()
	var stand_cyl: CylinderMesh = CylinderMesh.new()
	stand_cyl.top_radius = 0.045
	stand_cyl.bottom_radius = 0.06
	stand_cyl.height = 0.45
	stand_cyl.radial_segments = 20
	stand_mesh.mesh = stand_cyl
	stand_mesh.material_override = _mat_cast_iron
	stand_mesh.position = Vector3(0, 0.28, -0.04)
	stand_mesh.rotation.x = deg_to_rad(-8.0)
	add_child(stand_mesh)

	# Pivot joint
	var pivot_sphere: MeshInstance3D = MeshInstance3D.new()
	var p_mesh: SphereMesh = SphereMesh.new()
	p_mesh.radius = 0.08
	p_mesh.height = 0.16
	pivot_sphere.mesh = p_mesh
	pivot_sphere.material_override = _mat_brass
	pivot_sphere.position = Vector3(0, 0.52, -0.07)
	add_child(pivot_sphere)

	# 4. Motor Housing & Chassis
	var motor_pos: Vector3 = Vector3(0, 0.55, -0.02)
	var motor_chassis: Node3D = Node3D.new()
	motor_chassis.name = "MotorChassis"
	motor_chassis.position = motor_pos
	add_child(motor_chassis)

	var motor_mesh: MeshInstance3D = MeshInstance3D.new()
	var m_cyl: CylinderMesh = CylinderMesh.new()
	m_cyl.top_radius = 0.15
	m_cyl.bottom_radius = 0.16
	m_cyl.height = 0.28
	m_cyl.radial_segments = 28
	motor_mesh.mesh = m_cyl
	motor_mesh.material_override = _mat_chrome
	motor_mesh.rotation.x = deg_to_rad(90.0)
	motor_chassis.add_child(motor_mesh)

	# Rear ventilation cap
	var rear_cap: MeshInstance3D = MeshInstance3D.new()
	var r_cap_mesh: SphereMesh = SphereMesh.new()
	r_cap_mesh.radius = 0.14
	r_cap_mesh.height = 0.14
	rear_cap.mesh = r_cap_mesh
	rear_cap.material_override = _mat_cast_iron
	rear_cap.position = Vector3(0, 0, -0.14)
	motor_chassis.add_child(rear_cap)

	# 5. Rear Wire Cage
	var rear_cage: MeshInstance3D = MeshInstance3D.new()
	rear_cage.name = "RearCage"
	rear_cage.position = motor_pos + Vector3(0, 0, 0.04)
	rear_cage.mesh = _generate_cage_mesh(0.46, false)
	rear_cage.material_override = _mat_wire
	add_child(rear_cage)

	# 6. Motor Bearing (Damaged/Grime component that requires cleaning)
	var bearing_part: PartNode = PartNode.new()
	bearing_part.name = "MotorBearing"
	bearing_part.part_id = "MotorBearing"
	bearing_part.display_name = "Central Motor Bearing"
	bearing_part.prerequisite_part_ids = ["Blades"]
	bearing_part.required_tool = "cleaner_brush"
	bearing_part.is_damaged = true
	bearing_part.repair_description = "Brush away hardened vintage grease and debris"
	bearing_part.position = motor_pos + Vector3(0, 0, 0.07)
	add_child(bearing_part)

	var bearing_mesh: MeshInstance3D = MeshInstance3D.new()
	var b_cyl: CylinderMesh = CylinderMesh.new()
	b_cyl.top_radius = 0.055
	b_cyl.bottom_radius = 0.055
	b_cyl.height = 0.06
	bearing_mesh.mesh = b_cyl
	bearing_mesh.material_override = _mat_copper_grimy
	bearing_mesh.rotation.x = deg_to_rad(90.0)
	bearing_part.add_child(bearing_mesh)
	bearing_part.refresh_meshes()
	_attach_box_collision(bearing_part, Vector3(0.18, 0.18, 0.10))

	# 7. Blades Assembly
	var blades_part: PartNode = PartNode.new()
	blades_part.name = "Blades"
	blades_part.part_id = "Blades"
	blades_part.display_name = "Brass 4-Wing Blade Assembly"
	blades_part.prerequisite_part_ids = ["BladeLockNut", "FrontCage"]
	blades_part.required_tool = "none"
	blades_part.tray_slot_index = 2
	blades_part.detach_direction = Vector3(0, 0, 0.4)
	blades_part.position = motor_pos + Vector3(0, 0, 0.11)
	add_child(blades_part)
	blades_assembly = blades_part

	# Rotor center hub
	var rotor_hub: MeshInstance3D = MeshInstance3D.new()
	var r_cyl: CylinderMesh = CylinderMesh.new()
	r_cyl.top_radius = 0.06
	r_cyl.bottom_radius = 0.06
	r_cyl.height = 0.05
	rotor_hub.mesh = r_cyl
	rotor_hub.material_override = _mat_brass
	rotor_hub.rotation.x = deg_to_rad(90.0)
	blades_part.add_child(rotor_hub)

	# 4 aerofoil curved blades
	for i in range(4):
		var blade_angle: float = float(i) * (PI * 0.5)
		var blade_mesh: MeshInstance3D = MeshInstance3D.new()
		var b_box: BoxMesh = BoxMesh.new()
		b_box.size = Vector3(0.11, 0.32, 0.008)
		blade_mesh.mesh = b_box
		blade_mesh.material_override = _mat_brass
		blade_mesh.position = Vector3(sin(blade_angle) * 0.2, cos(blade_angle) * 0.2, 0)
		blade_mesh.rotation.z = -blade_angle + deg_to_rad(22.0)
		blade_mesh.rotation.y = deg_to_rad(18.0)
		blades_part.add_child(blade_mesh)

	blades_part.refresh_meshes()
	_attach_box_collision(blades_part, Vector3(0.65, 0.65, 0.08))

	# 8. Blade Lock Nut (Knurled brass cap)
	var lock_nut_part: PartNode = PartNode.new()
	lock_nut_part.name = "BladeLockNut"
	lock_nut_part.part_id = "BladeLockNut"
	lock_nut_part.display_name = "Rotor Spinner Lock Nut"
	lock_nut_part.prerequisite_part_ids = ["FrontCage"]
	lock_nut_part.required_tool = "none"
	lock_nut_part.tray_slot_index = 0
	lock_nut_part.is_screw = true
	lock_nut_part.detach_direction = Vector3(0, 0, 0.3)
	lock_nut_part.position = motor_pos + Vector3(0, 0, 0.15)
	add_child(lock_nut_part)

	var nut_mesh: MeshInstance3D = MeshInstance3D.new()
	var n_cyl: CylinderMesh = CylinderMesh.new()
	n_cyl.top_radius = 0.035
	n_cyl.bottom_radius = 0.04
	n_cyl.height = 0.04
	nut_mesh.mesh = n_cyl
	nut_mesh.material_override = _mat_brass
	nut_mesh.rotation.x = deg_to_rad(90.0)
	lock_nut_part.add_child(nut_mesh)
	lock_nut_part.refresh_meshes()
	_attach_box_collision(lock_nut_part, Vector3(0.16, 0.16, 0.10))

	# 9. Front Cage Guard
	var front_cage_part: PartNode = PartNode.new()
	front_cage_part.name = "FrontCage"
	front_cage_part.part_id = "FrontCage"
	front_cage_part.display_name = "Front Protective Wire Cage"
	front_cage_part.prerequisite_part_ids = ["Screw1", "Screw2", "Screw3", "Screw4"]
	front_cage_part.required_tool = "none"
	front_cage_part.tray_slot_index = 1
	front_cage_part.detach_direction = Vector3(0, 0, 0.45)
	front_cage_part.position = motor_pos + Vector3(0, 0, 0.16)
	add_child(front_cage_part)

	var front_cage_mesh: MeshInstance3D = MeshInstance3D.new()
	front_cage_mesh.mesh = _generate_cage_mesh(0.48, true)
	front_cage_mesh.material_override = _mat_wire
	front_cage_part.add_child(front_cage_mesh)

	# Center Technoir emblem badge
	var badge: MeshInstance3D = MeshInstance3D.new()
	var b_cyl2: CylinderMesh = CylinderMesh.new()
	b_cyl2.top_radius = 0.06
	b_cyl2.bottom_radius = 0.06
	b_cyl2.height = 0.012
	badge.mesh = b_cyl2
	badge.material_override = _mat_cast_iron
	badge.rotation.x = deg_to_rad(90.0)
	badge.position = Vector3(0, 0, 0.04)
	front_cage_part.add_child(badge)
	front_cage_part.refresh_meshes()
	_attach_box_collision(front_cage_part, Vector3(0.68, 0.68, 0.06))

	# 10. Four Fastener Screws
	var screw_positions: Array[Vector3] = [
		Vector3(0.0, 0.44, 0.18),    # Screw1 - Top
		Vector3(0.44, 0.0, 0.18),    # Screw2 - Right
		Vector3(0.0, -0.44, 0.18),   # Screw3 - Bottom
		Vector3(-0.44, 0.0, 0.18)    # Screw4 - Left
	]
	
	for i in range(4):
		var screw_id: String = "Screw%d" % (i + 1)
		var screw_part: PartNode = PartNode.new()
		screw_part.name = screw_id
		screw_part.part_id = screw_id
		screw_part.display_name = "Cage Clamp Screw #%d" % (i + 1)
		screw_part.prerequisite_part_ids = []
		screw_part.required_tool = "screwdriver"
		screw_part.tray_slot_index = 0
		screw_part.is_screw = true
		screw_part.detach_direction = Vector3(0, 0, 0.25)
		# Position proudly in front of the rim
		screw_part.position = motor_pos + screw_positions[i] + Vector3(0, 0, 0.02)
		add_child(screw_part)

		# Outer rim clamp bracket
		var bracket_mesh: MeshInstance3D = MeshInstance3D.new()
		var br_box: BoxMesh = BoxMesh.new()
		br_box.size = Vector3(0.06, 0.04, 0.02)
		bracket_mesh.mesh = br_box
		bracket_mesh.material_override = _mat_cast_iron
		bracket_mesh.position = Vector3(0, 0, -0.01)
		screw_part.add_child(bracket_mesh)

		# Slotted chrome screw head
		var s_mesh: MeshInstance3D = MeshInstance3D.new()
		var s_cyl: CylinderMesh = CylinderMesh.new()
		s_cyl.top_radius = 0.022
		s_cyl.bottom_radius = 0.018
		s_cyl.height = 0.032
		s_mesh.mesh = s_cyl
		s_mesh.material_override = _mat_chrome
		s_mesh.rotation.x = deg_to_rad(90.0)
		screw_part.add_child(s_mesh)
		
		screw_part.refresh_meshes()
		# Proud, generous hitbox for effortless finger tapping
		_attach_box_collision(screw_part, Vector3(0.18, 0.18, 0.14))

func _generate_cage_mesh(radius: float, is_front: bool) -> ImmediateMesh:
	var imm: ImmediateMesh = ImmediateMesh.new()
	var rings: int = 4
	var spokes: int = 12
	
	# Concentric wire rings
	for r_idx in range(1, rings + 1):
		var ring_r: float = radius * (float(r_idx) / float(rings))
		var z_offset: float = (1.0 - (float(r_idx) / float(rings))) * 0.05 if is_front else -(1.0 - (float(r_idx) / float(rings))) * 0.05
			
		imm.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		var steps: int = 32
		for s in range(steps + 1):
			var a: float = (float(s) / float(steps)) * TAU
			imm.surface_add_vertex(Vector3(cos(a) * ring_r, sin(a) * ring_r, z_offset))
		imm.surface_end()
		
	# Radial Spokes
	imm.surface_begin(Mesh.PRIMITIVE_LINES)
	for sp in range(spokes):
		var a: float = (float(sp) / float(spokes)) * TAU
		var z_front: float = 0.05 if is_front else -0.05
		imm.surface_add_vertex(Vector3(0, 0, z_front))
		imm.surface_add_vertex(Vector3(cos(a) * radius, sin(a) * radius, 0))
	imm.surface_end()
	
	return imm

func _attach_box_collision(parent_part: PartNode, box_size: Vector3) -> void:
	var area: Area3D = parent_part.get_node_or_null("Area3D") as Area3D
	if not area:
		area = Area3D.new()
		area.name = "Area3D"
		parent_part.add_child(area)
		
	var col: CollisionShape3D = area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if not col:
		col = CollisionShape3D.new()
		col.name = "CollisionShape3D"
		area.add_child(col)
		
	var box: BoxShape3D = BoxShape3D.new()
	box.size = box_size
	col.shape = box

func _process(delta: float) -> void:
	if _is_spinning and blades_assembly and not blades_assembly.is_detached:
		_current_spin_velocity = lerpf(_current_spin_velocity, _target_spin_velocity, delta * 2.5)
		blades_assembly.rotate_z(-_current_spin_velocity * delta)
	elif not _is_spinning and _current_spin_velocity > 0.01:
		_current_spin_velocity = lerpf(_current_spin_velocity, 0.0, delta * 1.5)
		if blades_assembly and not blades_assembly.is_detached:
			blades_assembly.rotate_z(-_current_spin_velocity * delta)

func on_test_run_started() -> void:
	_is_spinning = true
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(indicator_light, "light_energy", 1.8, 0.4)
	if switch_knob_mesh:
		tween.tween_property(switch_knob_mesh, "rotation:z", deg_to_rad(45.0), 0.2)
	_mat_lamp_glow.emission_energy_multiplier = 2.0

func on_test_run_stopped() -> void:
	_is_spinning = false
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(indicator_light, "light_energy", 0.0, 0.5)
	if switch_knob_mesh:
		tween.tween_property(switch_knob_mesh, "rotation:z", 0.0, 0.2)
	_mat_lamp_glow.emission_energy_multiplier = 0.0
