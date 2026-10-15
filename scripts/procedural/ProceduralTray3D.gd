class_name ProceduralTray3D
extends Node3D

## ProceduralTray3D
## Machined aluminum 3D organizer tray sitting on the workbench table to hold disassembled parts.

signal clicked()

var _mat_tray: StandardMaterial3D
var _mat_compartment: StandardMaterial3D

func _ready() -> void:
	_init_materials()
	_build_tray_mesh()
	_setup_collision()

func _init_materials() -> void:
	# Dark brushed vintage metal tray
	_mat_tray = StandardMaterial3D.new()
	_mat_tray.albedo_color = Color("2e3238")
	_mat_tray.metallic = 0.8
	_mat_tray.roughness = 0.35

	# Recessed dark compartment liners
	_mat_compartment = StandardMaterial3D.new()
	_mat_compartment.albedo_color = Color("181a1d")
	_mat_compartment.metallic = 0.3
	_mat_compartment.roughness = 0.85

func _build_tray_mesh() -> void:
	# Main tray outer frame: 0.30m wide, 0.024m high, 0.56m long
	var outer: MeshInstance3D = MeshInstance3D.new()
	var o_box: BoxMesh = BoxMesh.new()
	o_box.size = Vector3(0.30, 0.024, 0.56)
	outer.mesh = o_box
	outer.material_override = _mat_tray
	outer.position = Vector3(0, 0.012, 0)
	add_child(outer)

	# 3 Recessed compartments
	var compartment_sizes: Array[Vector3] = [
		Vector3(0.26, 0.018, 0.14), # Slot 1: Screws & small fasteners
		Vector3(0.26, 0.018, 0.16), # Slot 2: Cassette tape / lock nut
		Vector3(0.26, 0.018, 0.18)  # Slot 3: Chassis / cage
	]
	
	var compartment_z: Array[float] = [0.17, 0.0, -0.16]
	
	for i in range(3):
		var comp: MeshInstance3D = MeshInstance3D.new()
		var c_box: BoxMesh = BoxMesh.new()
		c_box.size = compartment_sizes[i]
		comp.mesh = c_box
		comp.material_override = _mat_compartment
		comp.position = Vector3(0, 0.018, compartment_z[i])
		add_child(comp)
		
		# Divider ridge
		if i < 2:
			var div: MeshInstance3D = MeshInstance3D.new()
			var d_box: BoxMesh = BoxMesh.new()
			d_box.size = Vector3(0.28, 0.026, 0.012)
			div.mesh = d_box
			div.material_override = _mat_tray
			div.position = Vector3(0, 0.014, (compartment_z[i] + compartment_z[i+1]) * 0.5)
			add_child(div)

func _setup_collision() -> void:
	var area: Area3D = Area3D.new()
	area.name = "Area3D"
	area.collision_layer = 1
	area.collision_mask = 0
	add_child(area)

	var col: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.32, 0.05, 0.58)
	col.shape = box
	col.position = Vector3(0, 0.025, 0)
	area.add_child(col)

func on_clicked() -> void:
	AudioManager.play_click(1.4)
	clicked.emit()
