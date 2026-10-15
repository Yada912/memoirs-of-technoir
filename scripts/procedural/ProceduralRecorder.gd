class_name ProceduralRecorder
extends RepairableObject

## ProceduralRecorder
## High-detail 3D Vintage Cassette Voice Recorder (1979 dictaphone).
## The primary interactive repair device for Chapter 1 of Memoirs of Technoir.

var cassette_door_part: PartNode
var cassette_tape_part: PartNode
var top_chassis_part: PartNode
var tape_head_part: PartNode
var play_button_part: PartNode
var stop_button_part: PartNode

var left_spool_mesh: MeshInstance3D
var right_spool_mesh: MeshInstance3D
var vu_led_mesh: MeshInstance3D
var vu_light: OmniLight3D
var play_key_mesh: MeshInstance3D

var _is_playing: bool = false
var _spool_rotation: float = 0.0

# Disassembly placement coordinates in world space (sitting in 3D tray and on table)
var table_slot_positions: Dictionary = {
	"Screw1": Vector3(-0.55, -0.28, 0.22),
	"Screw2": Vector3(-0.55, -0.28, 0.17),
	"Screw3": Vector3(-0.55, -0.28, 0.12),
	"Screw4": Vector3(-0.55, -0.28, 0.07),
	"CassetteTape": Vector3(-0.55, -0.28, -0.08),
	"CassetteDoor": Vector3(-0.35, -0.28, -0.15),
	"TopChassis": Vector3(-0.55, -0.28, -0.24)
}

# Materials
var _mat_chassis_dark: StandardMaterial3D
var _mat_aluminum_deck: StandardMaterial3D
var _mat_chrome: StandardMaterial3D
var _mat_acrylic_smoked: StandardMaterial3D
var _mat_cassette_shell: StandardMaterial3D
var _mat_tape_spool: StandardMaterial3D
var _mat_tape_ribbon: StandardMaterial3D
var _mat_grimy_head: StandardMaterial3D
var _mat_clean_head: StandardMaterial3D
var _mat_led: StandardMaterial3D
var _mat_label_gold: StandardMaterial3D

func _ready() -> void:
	object_name = "Vintage Technoir Voice Recorder"
	_init_materials()
	_build_recorder_structure()
	super._ready()

func _init_materials() -> void:
	# Charcoal ribbed chassis
	_mat_chassis_dark = StandardMaterial3D.new()
	_mat_chassis_dark.albedo_color = Color("23272d")
	_mat_chassis_dark.roughness = 0.65
	_mat_chassis_dark.metallic = 0.15

	# Brushed champagne aluminum top deck
	_mat_aluminum_deck = StandardMaterial3D.new()
	_mat_aluminum_deck.albedo_color = Color("c2b8a3")
	_mat_aluminum_deck.roughness = 0.35
	_mat_aluminum_deck.metallic = 0.75

	# Bright chrome trim & screws
	_mat_chrome = StandardMaterial3D.new()
	_mat_chrome.albedo_color = Color("dbe0ea")
	_mat_chrome.metallic = 0.95
	_mat_chrome.roughness = 0.15

	# Smoked transparent acrylic cassette door
	_mat_acrylic_smoked = StandardMaterial3D.new()
	_mat_acrylic_smoked.albedo_color = Color(0.2, 0.22, 0.25, 0.55)
	_mat_acrylic_smoked.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_acrylic_smoked.roughness = 0.1
	_mat_acrylic_smoked.clearcoat_enabled = true

	# Cassette tape body
	_mat_cassette_shell = StandardMaterial3D.new()
	_mat_cassette_shell.albedo_color = Color("2a2926")
	_mat_cassette_shell.roughness = 0.4
	_mat_cassette_shell.metallic = 0.1

	# White tape spools
	_mat_tape_spool = StandardMaterial3D.new()
	_mat_tape_spool.albedo_color = Color("e8e6df")
	_mat_tape_spool.roughness = 0.3

	# Brown ferric magnetic tape ribbon
	_mat_tape_ribbon = StandardMaterial3D.new()
	_mat_tape_ribbon.albedo_color = Color("4a2e1d")
	_mat_tape_ribbon.roughness = 0.35

	# Oxide-caked tape head (grimy)
	_mat_grimy_head = StandardMaterial3D.new()
	_mat_grimy_head.albedo_color = Color("3d2c20")
	_mat_grimy_head.roughness = 0.85
	_mat_grimy_head.metallic = 0.3

	# Polished tape head
	_mat_clean_head = StandardMaterial3D.new()
	_mat_clean_head.albedo_color = Color("9aa1a6")
	_mat_clean_head.metallic = 0.92
	_mat_clean_head.roughness = 0.15

	# Green VU LED
	_mat_led = StandardMaterial3D.new()
	_mat_led.albedo_color = Color("34d399")
	_mat_led.emission_enabled = true
	_mat_led.emission = Color("34d399")
	_mat_led.emission_energy_multiplier = 0.0

	# Technoir Gold label
	_mat_label_gold = StandardMaterial3D.new()
	_mat_label_gold.albedo_color = Color("bb8b24")
	_mat_label_gold.metallic = 0.6
	_mat_label_gold.roughness = 0.4

func _build_recorder_structure() -> void:
	# 1. Main Bottom Chassis Body (Fixed Base)
	var body: MeshInstance3D = MeshInstance3D.new()
	var b_box: BoxMesh = BoxMesh.new()
	b_box.size = Vector3(0.50, 0.10, 0.36)
	body.mesh = b_box
	body.material_override = _mat_chassis_dark
	body.position = Vector3(0, 0.05, 0)
	add_child(body)

	# Speaker grille on right side
	var speaker: MeshInstance3D = MeshInstance3D.new()
	var sp_cyl: CylinderMesh = CylinderMesh.new()
	sp_cyl.top_radius = 0.075
	sp_cyl.bottom_radius = 0.075
	sp_cyl.height = 0.005
	speaker.mesh = sp_cyl
	speaker.material_override = _mat_chassis_dark
	speaker.position = Vector3(0.14, 0.103, -0.02)
	add_child(speaker)

	# 2. Four Corner Enclosure Fasteners (Require Screwdriver)
	var screw_coords: Array[Vector3] = [
		Vector3(-0.22, 0.115, -0.15), # Screw1 - Rear Left
		Vector3(0.22, 0.115, -0.15),  # Screw2 - Rear Right
		Vector3(0.22, 0.115, 0.15),   # Screw3 - Front Right
		Vector3(-0.22, 0.115, 0.15)   # Screw4 - Front Left
	]
	
	for i in range(4):
		var screw_id: String = "Screw%d" % (i + 1)
		var screw: PartNode = PartNode.new()
		screw.name = screw_id
		screw.part_id = screw_id
		screw.display_name = "Chassis Anchor Screw #%d" % (i + 1)
		screw.required_tool = "screwdriver"
		screw.is_screw = true
		screw.detach_direction = Vector3(0, 0.25, 0)
		screw.position = screw_coords[i]
		add_child(screw)

		var s_mesh: MeshInstance3D = MeshInstance3D.new()
		var s_cyl: CylinderMesh = CylinderMesh.new()
		s_cyl.top_radius = 0.016
		s_cyl.bottom_radius = 0.014
		s_cyl.height = 0.022
		s_mesh.mesh = s_cyl
		s_mesh.material_override = _mat_chrome
		screw.add_child(s_mesh)
		
		screw.refresh_meshes()
		_attach_box_collision(screw, Vector3(0.12, 0.12, 0.12))

	# 3. Top Faceplate / Aluminum Control Deck (Detachable)
	top_chassis_part = PartNode.new()
	top_chassis_part.name = "TopChassis"
	top_chassis_part.part_id = "TopChassis"
	top_chassis_part.display_name = "Aluminum Control Faceplate"
	top_chassis_part.prerequisite_part_ids = ["Screw1", "Screw2", "Screw3", "Screw4"]
	top_chassis_part.required_tool = "none"
	top_chassis_part.detach_direction = Vector3(0, 0.35, 0)
	top_chassis_part.position = Vector3(0, 0.102, 0)
	add_child(top_chassis_part)

	var deck_mesh: MeshInstance3D = MeshInstance3D.new()
	var d_box: BoxMesh = BoxMesh.new()
	d_box.size = Vector3(0.48, 0.01, 0.34)
	deck_mesh.mesh = d_box
	deck_mesh.material_override = _mat_aluminum_deck
	top_chassis_part.add_child(deck_mesh)
	top_chassis_part.refresh_meshes()
	_attach_box_collision(top_chassis_part, Vector3(0.46, 0.06, 0.32))

	# 4. Cassette Door Window (Transparent Flap)
	cassette_door_part = PartNode.new()
	cassette_door_part.name = "CassetteDoor"
	cassette_door_part.part_id = "CassetteDoor"
	cassette_door_part.display_name = "Smoked Acrylic Cassette Door"
	cassette_door_part.prerequisite_part_ids = []
	cassette_door_part.required_tool = "none"
	cassette_door_part.detach_direction = Vector3(0, 0.25, 0.15)
	cassette_door_part.position = Vector3(-0.08, 0.112, -0.02)
	add_child(cassette_door_part)

	var door_mesh: MeshInstance3D = MeshInstance3D.new()
	var dr_box: BoxMesh = BoxMesh.new()
	dr_box.size = Vector3(0.24, 0.012, 0.17)
	door_mesh.mesh = dr_box
	door_mesh.material_override = _mat_acrylic_smoked
	cassette_door_part.add_child(door_mesh)
	cassette_door_part.refresh_meshes()
	_attach_box_collision(cassette_door_part, Vector3(0.25, 0.08, 0.18))

	# 5. Compact Cassette Tape (Inside the Well)
	cassette_tape_part = PartNode.new()
	cassette_tape_part.name = "CassetteTape"
	cassette_tape_part.part_id = "CassetteTape"
	cassette_tape_part.display_name = "Memoirs Cassette Tape (Side A)"
	cassette_tape_part.prerequisite_part_ids = ["CassetteDoor"]
	cassette_tape_part.required_tool = "none"
	cassette_tape_part.detach_direction = Vector3(0, 0.28, 0)
	cassette_tape_part.position = Vector3(-0.08, 0.095, -0.02)
	add_child(cassette_tape_part)

	var tape_body: MeshInstance3D = MeshInstance3D.new()
	var t_box: BoxMesh = BoxMesh.new()
	t_box.size = Vector3(0.20, 0.022, 0.13)
	tape_body.mesh = t_box
	tape_body.material_override = _mat_cassette_shell
	cassette_tape_part.add_child(tape_body)

	# Tape label
	var label: MeshInstance3D = MeshInstance3D.new()
	var l_box: BoxMesh = BoxMesh.new()
	l_box.size = Vector3(0.14, 0.023, 0.07)
	label.mesh = l_box
	label.material_override = _mat_label_gold
	label.position = Vector3(0, 0.001, 0)
	cassette_tape_part.add_child(label)

	# Left spool
	left_spool_mesh = MeshInstance3D.new()
	var s_cyl1: CylinderMesh = CylinderMesh.new()
	s_cyl1.top_radius = 0.022
	s_cyl1.bottom_radius = 0.022
	s_cyl1.height = 0.024
	s_cyl1.radial_segments = 16
	left_spool_mesh.mesh = s_cyl1
	left_spool_mesh.material_override = _mat_tape_spool
	left_spool_mesh.position = Vector3(-0.045, 0.002, 0)
	cassette_tape_part.add_child(left_spool_mesh)

	# Right spool
	right_spool_mesh = MeshInstance3D.new()
	var s_cyl2: CylinderMesh = CylinderMesh.new()
	s_cyl2.top_radius = 0.022
	s_cyl2.bottom_radius = 0.022
	s_cyl2.height = 0.024
	s_cyl2.radial_segments = 16
	right_spool_mesh.mesh = s_cyl2
	right_spool_mesh.material_override = _mat_tape_spool
	right_spool_mesh.position = Vector3(0.045, 0.002, 0)
	cassette_tape_part.add_child(right_spool_mesh)

	cassette_tape_part.refresh_meshes()
	_attach_box_collision(cassette_tape_part, Vector3(0.22, 0.06, 0.14))

	# 6. Tape Head & Capstan Drive Assembly (Damaged / Needs Cleaning)
	tape_head_part = PartNode.new()
	tape_head_part.name = "TapeHead"
	tape_head_part.part_id = "TapeHead"
	tape_head_part.display_name = "Magnetic Tape Read Head & Capstan"
	tape_head_part.prerequisite_part_ids = ["CassetteTape", "TopChassis"]
	tape_head_part.required_tool = "cleaner_brush"
	tape_head_part.is_damaged = true
	tape_head_part.repair_description = "Brush away hardened oxide dust from magnetic playback head"
	tape_head_part.position = Vector3(-0.08, 0.088, 0.055)
	add_child(tape_head_part)

	var head_mesh: MeshInstance3D = MeshInstance3D.new()
	var h_box: BoxMesh = BoxMesh.new()
	h_box.size = Vector3(0.045, 0.03, 0.025)
	head_mesh.mesh = h_box
	head_mesh.material_override = _mat_grimy_head
	tape_head_part.add_child(head_mesh)
	
	# Rubber pinch roller beside head
	var roller: MeshInstance3D = MeshInstance3D.new()
	var r_cyl: CylinderMesh = CylinderMesh.new()
	r_cyl.top_radius = 0.012
	r_cyl.bottom_radius = 0.012
	r_cyl.height = 0.025
	roller.mesh = r_cyl
	roller.material_override = _mat_grimy_head
	roller.position = Vector3(0.04, 0, 0)
	tape_head_part.add_child(roller)

	tape_head_part.refresh_meshes()
	_attach_box_collision(tape_head_part, Vector3(0.14, 0.10, 0.10))

	# 7. Piano Transport Keys on Front Edge
	# Play Key (On-Machine Test Run Button!)
	play_button_part = PartNode.new()
	play_button_part.name = "PlayButton"
	play_button_part.part_id = "PlayButton"
	play_button_part.display_name = "Mechanical PLAY Key"
	play_button_part.required_tool = "none"
	play_button_part.position = Vector3(-0.14, 0.105, 0.14)
	add_child(play_button_part)

	play_key_mesh = MeshInstance3D.new()
	var pk_box: BoxMesh = BoxMesh.new()
	pk_box.size = Vector3(0.055, 0.024, 0.048)
	play_key_mesh.mesh = pk_box
	play_key_mesh.material_override = _mat_chrome
	play_button_part.add_child(play_key_mesh)
	play_button_part.refresh_meshes()
	_attach_box_collision(play_button_part, Vector3(0.08, 0.08, 0.08))

	# Stop Key
	stop_button_part = PartNode.new()
	stop_button_part.name = "StopButton"
	stop_button_part.part_id = "StopButton"
	stop_button_part.display_name = "Mechanical STOP / EJECT Key"
	stop_button_part.required_tool = "none"
	stop_button_part.position = Vector3(-0.07, 0.105, 0.14)
	add_child(stop_button_part)

	var sk_mesh: MeshInstance3D = MeshInstance3D.new()
	var sk_box: BoxMesh = BoxMesh.new()
	sk_box.size = Vector3(0.055, 0.024, 0.048)
	sk_mesh.mesh = sk_box
	sk_mesh.material_override = _mat_chassis_dark
	stop_button_part.add_child(sk_mesh)
	stop_button_part.refresh_meshes()
	_attach_box_collision(stop_button_part, Vector3(0.08, 0.08, 0.08))

	# 8. VU Level Indicator Light
	vu_led_mesh = MeshInstance3D.new()
	var led_box: BoxMesh = BoxMesh.new()
	led_box.size = Vector3(0.016, 0.008, 0.028)
	vu_led_mesh.mesh = led_box
	vu_led_mesh.material_override = _mat_led
	vu_led_mesh.position = Vector3(0.06, 0.108, 0.14)
	add_child(vu_led_mesh)

	vu_light = OmniLight3D.new()
	vu_light.light_color = Color("34d399")
	vu_light.light_energy = 0.0
	vu_light.omni_range = 0.5
	vu_light.position = vu_led_mesh.position + Vector3(0, 0.03, 0)
	add_child(vu_light)

func _process(delta: float) -> void:
	if _is_playing and cassette_tape_part and not cassette_tape_part.is_detached:
		_spool_rotation += delta * 6.0
		if left_spool_mesh:
			left_spool_mesh.rotation.y = _spool_rotation
		if right_spool_mesh:
			right_spool_mesh.rotation.y = _spool_rotation

func on_test_run_started() -> void:
	_is_playing = true
	if vu_light:
		vu_light.light_energy = 1.8
	if play_key_mesh:
		var tween: Tween = create_tween()
		tween.tween_property(play_key_mesh, "position:y", -0.012, 0.15).set_trans(Tween.TRANS_QUAD)
	_mat_led.emission_energy_multiplier = 3.0
	AudioManager.start_cassette_playback()

func on_test_run_stopped() -> void:
	_is_playing = false
	if vu_light:
		vu_light.light_energy = 0.0
	if play_key_mesh:
		var tween: Tween = create_tween()
		tween.tween_property(play_key_mesh, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_BACK)
	_mat_led.emission_energy_multiplier = 0.0
	AudioManager.stop_cassette_playback()

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
