extends Node

## GameManager Singleton
## Manages high-level game state, chapter transitions, settings, and player progression.

const ChapterData = preload("res://scripts/data/ChapterData.gd")
const SETTINGS_PATH: String = "user://settings.cfg"

signal state_changed(new_state: State, old_state: State)
signal chapter_loaded(chapter_data: ChapterData)
signal repair_progress_updated(repaired_count: int, total_count: int)
signal chapter_completed(chapter_id: String)
signal settings_applied()

enum State {
	START_SCREEN,
	HOME_SCREEN,
	CHAPTER_SELECT,
	STORY_READER,
	WORKSTATION_3D,
	SETTINGS
}

var current_state: State = State.START_SCREEN
var previous_state: State = State.HOME_SCREEN
var active_chapter: ChapterData
var completed_chapters: Array[String] = []

var settings: Dictionary = {
	"master_volume": 0.85,
	"music_volume": 0.75,
	"sfx_volume": 0.90,
	"orbit_sensitivity": 0.0055,
	"invert_orbit": false,
	"vibration_enabled": true,
	"target_fps_60": true,
	"language": "en"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	apply_settings()

func change_state(new_state: State) -> void:
	if current_state != new_state:
		previous_state = current_state
		current_state = new_state
		AudioManager.play_click()
		state_changed.emit(current_state, previous_state)

func return_from_settings() -> void:
	if previous_state == State.SETTINGS:
		change_state(State.HOME_SCREEN)
	else:
		change_state(previous_state)

func load_chapter(chapter_resource: ChapterData) -> void:
	active_chapter = chapter_resource
	chapter_loaded.emit(active_chapter)
	change_state(State.STORY_READER)

func enter_workstation() -> void:
	change_state(State.WORKSTATION_3D)

func mark_chapter_complete(chapter_id: String) -> void:
	if not completed_chapters.has(chapter_id):
		completed_chapters.append(chapter_id)
	chapter_completed.emit(chapter_id)

func is_chapter_completed(chapter_id: String) -> bool:
	return completed_chapters.has(chapter_id)

func load_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err = cfg.load(SETTINGS_PATH)
	if err == OK:
		for k in settings.keys():
			if cfg.has_section_key("settings", k):
				settings[k] = cfg.get_value("settings", k, settings[k])

func save_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	for k in settings.keys():
		cfg.set_value("settings", k, settings[k])
	cfg.save(SETTINGS_PATH)
	apply_settings()

func apply_settings() -> void:
	AudioManager.set_master_volume(settings.get("master_volume", 0.85))
	AudioManager.set_music_volume(settings.get("music_volume", 0.75))
	AudioManager.set_sfx_volume(settings.get("sfx_volume", 0.90))
	
	if settings.get("target_fps_60", true):
		Engine.max_fps = 60
	else:
		Engine.max_fps = 30
		
	settings_applied.emit()
