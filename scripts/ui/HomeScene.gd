class_name HomeScene
extends Control

## HomeScene
## Main menu matching Figma "home scene" (node 2010:449).

signal continue_pressed()
signal chapters_pressed()
signal settings_pressed()

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = UIStyleHelper.COLOR_BG_NIGHT
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	var container: VBoxContainer = VBoxContainer.new()
	container.set_anchors_preset(PRESET_FULL_RECT)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 20)
	add_child(container)
	
	# Top Logo
	var logo_center: CenterContainer = CenterContainer.new()
	var logo: TechnoirLogo = TechnoirLogo.new()
	logo.custom_minimum_size = Vector2(110, 110)
	logo.logo_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	logo_center.add_child(logo)
	container.add_child(logo_center)
	
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	container.add_child(spacer)
	
	# Buttons Stack
	var btn_width: float = 290.0
	var btn_height: float = 58.0
	
	# 1. Continue
	var btn_continue: Button = Button.new()
	btn_continue.text = "Continue"
	btn_continue.custom_minimum_size = Vector2(btn_width, btn_height)
	UIStyleHelper.style_button(btn_continue, true)
	btn_continue.pressed.connect(_on_continue_pressed)
	var c_wrap: CenterContainer = CenterContainer.new()
	c_wrap.add_child(btn_continue)
	container.add_child(c_wrap)
	
	# 2. Chapters
	var btn_chapters: Button = Button.new()
	btn_chapters.text = "Chapters"
	btn_chapters.custom_minimum_size = Vector2(btn_width, btn_height)
	UIStyleHelper.style_button(btn_chapters, false)
	btn_chapters.pressed.connect(_on_chapters_pressed)
	var ch_wrap: CenterContainer = CenterContainer.new()
	ch_wrap.add_child(btn_chapters)
	container.add_child(ch_wrap)
	
	# 3. Gallery (Disabled / preview)
	var btn_gallery: Button = Button.new()
	btn_gallery.text = "Gallery"
	btn_gallery.custom_minimum_size = Vector2(btn_width, btn_height)
	UIStyleHelper.style_button(btn_gallery, false)
	btn_gallery.disabled = true
	btn_gallery.modulate.a = 0.5
	var g_wrap: CenterContainer = CenterContainer.new()
	g_wrap.add_child(btn_gallery)
	container.add_child(g_wrap)
	
	# 4. Settings
	var btn_settings: Button = Button.new()
	btn_settings.text = "Settings"
	btn_settings.custom_minimum_size = Vector2(btn_width, btn_height)
	UIStyleHelper.style_button(btn_settings, false)
	btn_settings.pressed.connect(_on_settings_pressed)
	var s_wrap: CenterContainer = CenterContainer.new()
	s_wrap.add_child(btn_settings)
	container.add_child(s_wrap)
	
	# Footer Text
	var footer: Label = Label.new()
	footer.text = "still in development\nMemoirs of Technoir 2026"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color("5c6270"))
	footer.set_anchors_preset(PRESET_BOTTOM_WIDE)
	footer.position.y = -60
	add_child(footer)

func _on_continue_pressed() -> void:
	continue_pressed.emit()
	var ch1: ChapterData = load("res://resources/chapters/Chapter1.tres")
	GameManager.load_chapter(ch1)

func _on_chapters_pressed() -> void:
	chapters_pressed.emit()
	GameManager.change_state(GameManager.State.CHAPTER_SELECT)

func _on_settings_pressed() -> void:
	settings_pressed.emit()
	GameManager.change_state(GameManager.State.SETTINGS)
