class_name SettingsScene
extends Control

## SettingsScene
## Fully functional Settings screen matching Memoirs of Technoir visual theme:
## Controls Master, Music, SFX volume, touch sensitivity, vibration, and language.

var _slider_master: HSlider
var _slider_music: HSlider
var _slider_sfx: HSlider
var _slider_sensitivity: HSlider
var _check_vibration: CheckButton
var _check_fps: CheckButton
var _opt_language: OptionButton

var _lbl_master_val: Label
var _lbl_music_val: Label
var _lbl_sfx_val: Label

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Background
	var bg: ColorRect = ColorRect.new()
	bg.color = UIStyleHelper.COLOR_BG_NIGHT
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)

	# Fixed Top Bar
	var nav_bar: TopNavBar = TopNavBar.new()
	nav_bar.set_anchors_preset(PRESET_TOP_WIDE)
	nav_bar.back_pressed.connect(func(): GameManager.return_from_settings())
	add_child(nav_bar)

	# Main Card Container
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(scroll)

	var center_wrap: CenterContainer = CenterContainer.new()
	center_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_wrap.custom_minimum_size = Vector2(412, 850)
	scroll.add_child(center_wrap)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(350, 680)
	panel.add_theme_stylebox_override("panel", UIStyleHelper.create_card_panel_style())
	center_wrap.add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# Title
	var title: Label = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY)
	vbox.add_child(title)

	# --- AUDIO SECTION ---
	_add_section_header(vbox, "AUDIO")
	
	# Master Volume
	var m_row: HBoxContainer = _create_slider_row("Master Volume", GameManager.settings.get("master_volume", 0.85))
	_slider_master = m_row.get_node("Slider") as HSlider
	_lbl_master_val = m_row.get_node("Val") as Label
	_slider_master.value_changed.connect(func(v):
		GameManager.settings["master_volume"] = v
		_lbl_master_val.text = "%d%%" % int(v * 100)
		AudioManager.set_master_volume(v)
	)
	vbox.add_child(m_row)

	# Music Volume
	var mu_row: HBoxContainer = _create_slider_row("Music Volume", GameManager.settings.get("music_volume", 0.75))
	_slider_music = mu_row.get_node("Slider") as HSlider
	_lbl_music_val = mu_row.get_node("Val") as Label
	_slider_music.value_changed.connect(func(v):
		GameManager.settings["music_volume"] = v
		_lbl_music_val.text = "%d%%" % int(v * 100)
		AudioManager.set_music_volume(v)
	)
	vbox.add_child(mu_row)

	# SFX Volume
	var s_row: HBoxContainer = _create_slider_row("SFX Volume", GameManager.settings.get("sfx_volume", 0.90))
	_slider_sfx = s_row.get_node("Slider") as HSlider
	_lbl_sfx_val = s_row.get_node("Val") as Label
	_slider_sfx.value_changed.connect(func(v):
		GameManager.settings["sfx_volume"] = v
		_lbl_sfx_val.text = "%d%%" % int(v * 100)
		AudioManager.set_sfx_volume(v)
		AudioManager.play_click()
	)
	vbox.add_child(s_row)

	# --- CONTROLS SECTION ---
	_add_section_header(vbox, "TOUCH & CAMERA")
	
	# Orbit Sensitivity
	var sens_row: HBoxContainer = _create_slider_row("Orbit Sensitivity", GameManager.settings.get("orbit_sensitivity", 0.0055) * 100.0, 0.2, 1.5, 0.05)
	_slider_sensitivity = sens_row.get_node("Slider") as HSlider
	var lbl_sens: Label = sens_row.get_node("Val") as Label
	lbl_sens.text = "%.1fx" % (_slider_sensitivity.value)
	_slider_sensitivity.value_changed.connect(func(v):
		GameManager.settings["orbit_sensitivity"] = v * 0.01
		lbl_sens.text = "%.1fx" % v
	)
	vbox.add_child(sens_row)

	# Vibration Haptics
	var vib_row: HBoxContainer = HBoxContainer.new()
	var vib_lbl: Label = Label.new()
	vib_lbl.text = "Touch Vibration"
	vib_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vib_row.add_child(vib_lbl)
	_check_vibration = CheckButton.new()
	_check_vibration.button_pressed = GameManager.settings.get("vibration_enabled", true)
	_check_vibration.toggled.connect(func(b): GameManager.settings["vibration_enabled"] = b)
	vib_row.add_child(_check_vibration)
	vbox.add_child(vib_row)

	# 60 FPS Target
	var fps_row: HBoxContainer = HBoxContainer.new()
	var fps_lbl: Label = Label.new()
	fps_lbl.text = "High Frame Rate (60 FPS)"
	fps_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fps_row.add_child(fps_lbl)
	_check_fps = CheckButton.new()
	_check_fps.button_pressed = GameManager.settings.get("target_fps_60", true)
	_check_fps.toggled.connect(func(b): GameManager.settings["target_fps_60"] = b)
	fps_row.add_child(_check_fps)
	vbox.add_child(fps_row)

	# --- LANGUAGE SECTION ---
	_add_section_header(vbox, "LANGUAGE")
	var lang_row: HBoxContainer = HBoxContainer.new()
	var lang_lbl: Label = Label.new()
	lang_lbl.text = "Language / Bahasa"
	lang_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lang_row.add_child(lang_lbl)
	_opt_language = OptionButton.new()
	_opt_language.add_item("English", 0)
	_opt_language.add_item("Bahasa Indonesia", 1)
	_opt_language.selected = 1 if GameManager.settings.get("language", "en") == "id" else 0
	_opt_language.item_selected.connect(func(idx):
		GameManager.settings["language"] = "id" if idx == 1 else "en"
	)
	lang_row.add_child(_opt_language)
	vbox.add_child(lang_row)

	# Spacer
	var sp: Control = Control.new()
	sp.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(sp)

	# Save & Back Button
	var btn_save: Button = Button.new()
	btn_save.text = "Save & Apply"
	btn_save.custom_minimum_size = Vector2(0, 48)
	UIStyleHelper.style_button(btn_save, true)
	btn_save.pressed.connect(_on_save_pressed)
	vbox.add_child(btn_save)

	# Reset Defaults Button
	var btn_reset: Button = Button.new()
	btn_reset.text = "Reset Defaults"
	btn_reset.custom_minimum_size = Vector2(0, 40)
	UIStyleHelper.style_button(btn_reset, false)
	btn_reset.pressed.connect(_on_reset_pressed)
	vbox.add_child(btn_reset)

func _add_section_header(parent: VBoxContainer, text: String) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color("8c94a6"))
	parent.add_child(lbl)

func _create_slider_row(label_text: String, init_val: float, min_v: float = 0.0, max_v: float = 1.0, step: float = 0.01) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(lbl)
	
	var slider: HSlider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = init_val
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(110, 24)
	row.add_child(slider)
	
	var val_lbl: Label = Label.new()
	val_lbl.name = "Val"
	val_lbl.text = "%d%%" % int(init_val * 100)
	val_lbl.custom_minimum_size = Vector2(44, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_lbl.add_theme_font_size_override("font_size", 12)
	row.add_child(val_lbl)
	
	return row

func _on_save_pressed() -> void:
	AudioManager.play_click()
	GameManager.save_settings()
	GameManager.return_from_settings()

func _on_reset_pressed() -> void:
	AudioManager.play_click()
	GameManager.settings = {
		"master_volume": 0.85,
		"music_volume": 0.75,
		"sfx_volume": 0.90,
		"orbit_sensitivity": 0.0055,
		"invert_orbit": false,
		"vibration_enabled": true,
		"target_fps_60": true,
		"language": "en"
	}
	GameManager.save_settings()
	_slider_master.value = 0.85
	_slider_music.value = 0.75
	_slider_sfx.value = 0.90
	_slider_sensitivity.value = 0.55
	_check_vibration.button_pressed = true
	_check_fps.button_pressed = true
	_opt_language.selected = 0
