class_name TopNavBar
extends Control

## TopNavBar
## Consistent top navigation bar strictly matching the Figma header component (node 2024:513):
## - Back button with Google Material arrow_back (x=20, y=23, 40x40)
## - Central Technoir cassette logo emblem (x=188, y=25, 35x35)
## - Settings/Menu button with Google Material settings (x=352, y=23, 40x40)

signal back_pressed()
signal menu_pressed()

@export var title_override: String = ""

var _btn_back: Button
var _btn_menu: Button
var _logo: TechnoirLogo

func _ready() -> void:
	custom_minimum_size = Vector2(0, 68)
	mouse_filter = MOUSE_FILTER_IGNORE
	_setup_bar()

func _setup_bar() -> void:
	# 1. Back Button (Left, 40x40, matching Figma)
	_btn_back = Button.new()
	_btn_back.custom_minimum_size = Vector2(40, 40)
	_btn_back.size = Vector2(40, 40)
	_btn_back.position = Vector2(20, 14)
	_btn_back.icon = load("res://assets/icons/arrow_back.svg")
	_btn_back.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_btn_back.expand_icon = true
	UIStyleHelper.style_icon_button(_btn_back)
	_btn_back.pressed.connect(_on_back_pressed)
	add_child(_btn_back)
	
	# 2. Center Technoir Logo
	_logo = TechnoirLogo.new()
	_logo.custom_minimum_size = Vector2(38, 38)
	_logo.size = Vector2(38, 38)
	_logo.set_anchors_preset(PRESET_CENTER_TOP)
	_logo.position = Vector2(-19, 15)
	_logo.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_logo)
	
	# 3. Settings / Menu Button (Right, 40x40, matching Figma)
	_btn_menu = Button.new()
	_btn_menu.custom_minimum_size = Vector2(40, 40)
	_btn_menu.size = Vector2(40, 40)
	_btn_menu.set_anchors_preset(PRESET_TOP_RIGHT)
	_btn_menu.position = Vector2(-60, 14)
	_btn_menu.icon = load("res://assets/icons/settings.svg")
	_btn_menu.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_btn_menu.expand_icon = true
	UIStyleHelper.style_icon_button(_btn_menu)
	_btn_menu.pressed.connect(_on_menu_pressed)
	add_child(_btn_menu)

func _on_back_pressed() -> void:
	AudioManager.play_click()
	back_pressed.emit()

func _on_menu_pressed() -> void:
	AudioManager.play_click()
	menu_pressed.emit()
	GameManager.change_state(GameManager.State.SETTINGS)
