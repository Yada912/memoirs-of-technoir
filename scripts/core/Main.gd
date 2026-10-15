class_name Main
extends Control

## Main
## Master scene manager coordinating screen state transitions with cross-fade animations.

@export var start_scene_script: GDScript = preload("res://scripts/ui/StartScene.gd")
@export var home_scene_script: GDScript = preload("res://scripts/ui/HomeScene.gd")
@export var chapter_select_script: GDScript = preload("res://scripts/ui/ChapterSelect.gd")
@export var story_reader_script: GDScript = preload("res://scripts/ui/StoryReader2D.gd")
@export var workstation_scene_script: GDScript = preload("res://scripts/controllers/WorkstationScene.gd")
@export var settings_scene_script: GDScript = preload("res://scripts/ui/SettingsScene.gd")

var _content_root: Control
var _fade_overlay: ColorRect
var _current_view: Node
var _is_transitioning: bool = false

func _ready() -> void:
	_setup_containers()
	GameManager.state_changed.connect(_on_game_state_changed)
	_load_state_view(GameManager.current_state, false)

func _setup_containers() -> void:
	# Content Viewport Root
	_content_root = Control.new()
	_content_root.name = "ContentRoot"
	_content_root.set_anchors_preset(PRESET_FULL_RECT)
	add_child(_content_root)
	
	# Fullscreen Black Fade Transition Overlay
	_fade_overlay = ColorRect.new()
	_fade_overlay.name = "FadeOverlay"
	_fade_overlay.color = Color("0a0d14", 0.0)
	_fade_overlay.mouse_filter = MOUSE_FILTER_IGNORE
	_fade_overlay.set_anchors_preset(PRESET_FULL_RECT)
	add_child(_fade_overlay)

func _notification(what: int) -> void:
	# Android Hardware Back Button Support
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_android_back()

func _handle_android_back() -> void:
	match GameManager.current_state:
		GameManager.State.WORKSTATION_3D:
			GameManager.change_state(GameManager.State.STORY_READER)
		GameManager.State.STORY_READER:
			GameManager.change_state(GameManager.State.CHAPTER_SELECT)
		GameManager.State.CHAPTER_SELECT:
			GameManager.change_state(GameManager.State.HOME_SCREEN)
		GameManager.State.HOME_SCREEN:
			GameManager.change_state(GameManager.State.START_SCREEN)
		GameManager.State.START_SCREEN:
			get_tree().quit()

func _on_game_state_changed(new_state: GameManager.State, _old_state: GameManager.State) -> void:
	_load_state_view(new_state, true)

func _load_state_view(state: GameManager.State, use_fade: bool) -> void:
	if _is_transitioning:
		return
		
	if use_fade:
		_is_transitioning = true
		_fade_overlay.mouse_filter = MOUSE_FILTER_STOP
		var fade_in: Tween = create_tween()
		fade_in.tween_property(_fade_overlay, "color:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
		await fade_in.finished
		
		_replace_current_view(state)
		
		var fade_out: Tween = create_tween()
		fade_out.tween_property(_fade_overlay, "color:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)
		await fade_out.finished
		_fade_overlay.mouse_filter = MOUSE_FILTER_IGNORE
		_is_transitioning = false
	else:
		_replace_current_view(state)

func _replace_current_view(state: GameManager.State) -> void:
	if _current_view:
		_current_view.queue_free()
		_current_view = null
		
	match state:
		GameManager.State.START_SCREEN:
			_current_view = start_scene_script.new()
		GameManager.State.HOME_SCREEN:
			_current_view = home_scene_script.new()
		GameManager.State.CHAPTER_SELECT:
			_current_view = chapter_select_script.new()
		GameManager.State.STORY_READER:
			_current_view = story_reader_script.new()
		GameManager.State.WORKSTATION_3D:
			_current_view = workstation_scene_script.new()
		GameManager.State.SETTINGS:
			_current_view = settings_scene_script.new()
		_:
			_current_view = start_scene_script.new()
			
	if _current_view:
		if _current_view is Control:
			(_current_view as Control).set_anchors_preset(PRESET_FULL_RECT)
		_content_root.add_child(_current_view)
