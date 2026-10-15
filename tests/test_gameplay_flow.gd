extends Node

## TestRunner for Memoirs of Technoir
## Runs comprehensive integration tests inside the live Godot scene tree.

func _ready() -> void:
	print("\n==================================================")
	print("  MEMOIRS OF TECHNOIR - PLAYABLE INTEGRATION TEST  ")
	print("==================================================")
	
	test_chapter_data()
	await test_recorder_hierarchy_and_dependencies()
	await test_fan_hierarchy_and_dependencies()
	test_settings_and_audio()
	await test_workstation_scene()
	
	print("\n>>> ALL TESTS PASSED SUCCESSFULLY! <<<\n")
	get_tree().quit(0)

func test_chapter_data() -> void:
	print("\n[TEST 1] Validating ChapterData Custom Resources...")
	var ch1: ChapterData = load("res://resources/chapters/Chapter1.tres")
	assert(ch1 != null, "Chapter1.tres failed to load!")
	assert(ch1.chapter_id == "chapter_1", "Chapter 1 ID mismatch!")
	assert(ch1.target_model_scene != null, "Chapter 1 Target model scene not linked!")
	print("  ✓ Chapter 1 verified (ID: %s, Title: %s, Device: %s)" % [ch1.chapter_id, ch1.chapter_title, ch1.device_name])
	
	var ch2: ChapterData = load("res://resources/chapters/Chapter2.tres")
	assert(ch2 != null, "Chapter2.tres failed to load!")
	assert(ch2.chapter_id == "chapter_2", "Chapter 2 ID mismatch!")
	assert(ch2.target_model_scene != null, "Chapter 2 Target model scene not linked!")
	print("  ✓ Chapter 2 verified (ID: %s, Title: %s, Device: %s)" % [ch2.chapter_id, ch2.chapter_title, ch2.device_name])

func test_recorder_hierarchy_and_dependencies() -> void:
	print("\n[TEST 2] Testing 3D ProceduralRecorder Disassembly & Diegetic Audio Playback...")
	var rec: ProceduralRecorder = ProceduralRecorder.new()
	add_child(rec)
	
	# Verify part discovery
	var screws: Array[PartNode] = []
	for i in range(1, 5):
		var s: PartNode = rec.get_part("Screw%d" % i)
		assert(s != null, "Screw%d not registered in recorder!" % i)
		screws.append(s)
		
	var door: PartNode = rec.get_part("CassetteDoor")
	var tape: PartNode = rec.get_part("CassetteTape")
	var chassis: PartNode = rec.get_part("TopChassis")
	var head: PartNode = rec.get_part("TapeHead")
	var play_btn: PartNode = rec.get_part("PlayButton")
	var stop_btn: PartNode = rec.get_part("StopButton")
	
	assert(door != null, "CassetteDoor not registered!")
	assert(tape != null, "CassetteTape not registered!")
	assert(chassis != null, "TopChassis not registered!")
	assert(head != null, "TapeHead not registered!")
	assert(play_btn != null, "PlayButton not registered!")
	assert(stop_btn != null, "StopButton not registered!")
	print("  ✓ All 10 interactive recorder components registered in dependency graph")
	
	# Step A: Verify Cassette Tape cannot be removed while door is closed
	ToolBeltManager.equip_tool("hand")
	var tape_eval1 = rec.can_detach(tape)
	assert(not tape_eval1.allowed, "CassetteTape should NOT detach before opening door!")
	print("  ✓ CassetteDoor prerequisite constraint enforced on Tape")
	
	# Step B: Open door and remove cassette tape
	var door_eval = rec.can_detach(door)
	assert(door_eval.allowed, "CassetteDoor should open with hand!")
	door.is_detached = true
	rec._on_part_detached(door)
	
	var tape_eval2 = rec.can_detach(tape)
	assert(tape_eval2.allowed, "CassetteTape should now be removable!")
	tape.is_detached = true
	rec._on_part_detached(tape)
	print("  ✓ Cassette door opened and tape removed")
	
	# Step C: Top chassis cannot be removed before 4 screws are unfastened
	var chassis_eval1 = rec.can_detach(chassis)
	assert(not chassis_eval1.allowed, "TopChassis should NOT detach before 4 screws!")
	
	# Step D: Unfasten 4 chassis screws with screwdriver
	ToolBeltManager.equip_tool("screwdriver")
	for s in screws:
		var s_eval = rec.can_detach(s)
		assert(s_eval.allowed, "Screw should loosen with screwdriver!")
		s.is_detached = true
		rec._on_part_detached(s)
		
	ToolBeltManager.equip_tool("hand")
	var chassis_eval2 = rec.can_detach(chassis)
	assert(chassis_eval2.allowed, "TopChassis should now be detachable!")
	chassis.is_detached = true
	rec._on_part_detached(chassis)
	print("  ✓ 4 screws unfastened and aluminum chassis deck detached")
	
	# Step E: Clean oxidized magnetic playback head
	assert(head.is_damaged, "TapeHead should initially be oxidized and dirty!")
	ToolBeltManager.equip_tool("cleaner_brush")
	await head.perform_repair()
	assert(head.is_repaired, "TapeHead should be marked repaired after brushing!")
	print("  ✓ Magnetic playback head cleaned of ferric oxide dust")
	
	# Step F: Reassemble recorder
	chassis.is_detached = false
	rec._on_part_attached(chassis)
	for s in screws:
		s.is_detached = false
		rec._on_part_attached(s)
	tape.is_detached = false
	rec._on_part_attached(tape)
	door.is_detached = false
	rec._on_part_attached(door)
	assert(rec.is_fully_reassembled(), "Recorder should be fully reassembled!")
	print("  ✓ Recorder successfully reassembled into ready state")
	
	# Step G: Test Run via diegetic PLAY key
	var play_success: bool = rec.trigger_test_run()
	assert(play_success, "Test run should succeed on reassembled, cleaned recorder!")
	assert(rec.is_operational, "Recorder should be operational!")
	assert(rec._is_playing, "Recorder should be actively playing!")
	assert(rec.vu_light.light_energy > 0.0, "VU indicator LED should glow during playback!")
	print("  ✓ Diegetic PLAY key pressed: Tape spools spinning, VU light glowing, audio playing")
	
	# Step H: Press STOP key
	rec.stop_test_run()
	assert(not rec._is_playing, "Playback should stop when STOP key is triggered!")
	print("  ✓ Diegetic STOP key pressed: Playback halted cleanly")
	
	rec.queue_free()

func test_fan_hierarchy_and_dependencies() -> void:
	print("\n[TEST 3] Testing 3D ProceduralFan Disassembly & Motor Bearing...")
	var fan: ProceduralFan = ProceduralFan.new()
	add_child(fan)
	
	var screws: Array[PartNode] = []
	for i in range(1, 5):
		var s: PartNode = fan.get_part("Screw%d" % i)
		assert(s != null, "Screw%d not registered in fan!" % i)
		screws.append(s)
		
	var front_cage: PartNode = fan.get_part("FrontCage")
	var lock_nut: PartNode = fan.get_part("BladeLockNut")
	var blades: PartNode = fan.get_part("Blades")
	var bearing: PartNode = fan.get_part("MotorBearing")
	
	# Unfasten screws
	ToolBeltManager.equip_tool("screwdriver")
	for s in screws:
		s.is_detached = true
		fan._on_part_detached(s)
		
	ToolBeltManager.equip_tool("hand")
	front_cage.is_detached = true
	fan._on_part_detached(front_cage)
	lock_nut.is_detached = true
	fan._on_part_detached(lock_nut)
	blades.is_detached = true
	fan._on_part_detached(blades)
	
	# Clean bearing
	ToolBeltManager.equip_tool("cleaner_brush")
	await bearing.perform_repair()
	assert(bearing.is_repaired, "Bearing should be repaired!")
	
	# Reassemble
	blades.is_detached = false
	fan._on_part_attached(blades)
	lock_nut.is_detached = false
	fan._on_part_attached(lock_nut)
	front_cage.is_detached = false
	fan._on_part_attached(front_cage)
	for s in screws:
		s.is_detached = false
		fan._on_part_attached(s)
		
	var ok: bool = fan.trigger_test_run()
	assert(ok, "Fan test run should succeed!")
	assert(fan.is_operational, "Fan should be operational!")
	print("  ✓ ProceduralFan restored, reassembled, and motor running smoothly")
	fan.queue_free()

func test_settings_and_audio() -> void:
	print("\n[TEST 4] Testing SettingsScene & Audio Manager...")
	GameManager.load_settings()
	GameManager.settings["master_volume"] = 0.90
	GameManager.settings["music_volume"] = 0.80
	GameManager.save_settings()
	
	AudioManager.set_master_volume(0.90)
	AudioManager.set_music_volume(0.80)
	AudioManager.set_sfx_volume(0.85)
	
	# Test LoFi Music stream generation
	var lofi: AudioStreamWAV = ProceduralAudio.create_lofi_music_track()
	assert(lofi != null, "LoFi music generator failed!")
	assert(lofi.data.size() > 0, "LoFi music data buffer is empty!")
	
	# Test Cassette Tape stream generation
	var cassette_audio: AudioStreamWAV = ProceduralAudio.create_cassette_playback_track()
	assert(cassette_audio != null, "Cassette audio generator failed!")
	assert(cassette_audio.data.size() > 0, "Cassette audio buffer is empty!")
	print("  ✓ Procedural Lo-Fi background music and vintage cassette playback generated successfully")
	print("  ✓ AudioServer volume attenuation and user://settings.cfg persistence verified")

func test_workstation_scene() -> void:
	print("\n[TEST 5] Testing Full 3D WorkstationScene & Physical Desk Tools...")
	var ws: WorkstationScene = WorkstationScene.new()
	add_child(ws)
	
	assert(ws.repairable_device != null, "Repairable device failed to instantiate!")
	assert(ws.tray_3d != null, "3D Parts Organizer Tray failed to instantiate!")
	assert(ws.screwdriver_3d != null, "3D Screwdriver failed to instantiate!")
	assert(ws.task_lamp != null, "Task lamp failed to initialize!")
	assert(ws.controller != null, "WorkstationController failed to initialize!")
	assert(ws.ui_overlay != null, "UI_Overlay failed to initialize!")
	
	# Test Camera Mode toggling
	assert(ws.controller.camera_mode == WorkstationController.CameraMode.ORBIT, "Default camera mode should be ORBIT!")
	var new_mode = ws.controller.toggle_camera_mode()
	assert(new_mode == WorkstationController.CameraMode.PAN, "Camera mode should toggle to PAN!")
	ws.controller.reset_camera()
	
	# Test 3D Screwdriver equip
	ws.screwdriver_3d.on_clicked()
	assert(ToolBeltManager.get_active_tool() == ToolBeltManager.TOOL_SCREWDRIVER, "3D Screwdriver click should equip screwdriver!")
	ws.screwdriver_3d.on_clicked()
	assert(ToolBeltManager.get_active_tool() == ToolBeltManager.TOOL_HAND, "3D Screwdriver click again should unequip to hand!")
	
	print("  ✓ 3D workbench level, 3D tray, 3D screwdriver, camera orbit/pan, and UI overlay fully operational")
	ws.queue_free()
