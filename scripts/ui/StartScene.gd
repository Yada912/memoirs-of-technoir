class_name StartScene
extends Control

## StartScene
## Initial splash/title screen matching Figma "sart scene" (node 2010:349).

signal start_pressed()

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Dark cozy late night background
	var bg: ColorRect = ColorRect.new()
	bg.color = UIStyleHelper.COLOR_BG_NIGHT
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	var container: VBoxContainer = VBoxContainer.new()
	container.set_anchors_preset(PRESET_FULL_RECT)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 32)
	add_child(container)
	
	# Spacer
	var spacer_top: Control = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 40)
	container.add_child(spacer_top)
	
	# Centered Logo
	var logo_center: CenterContainer = CenterContainer.new()
	var logo: TechnoirLogo = TechnoirLogo.new()
	logo.custom_minimum_size = Vector2(130, 130)
	logo.logo_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	logo_center.add_child(logo)
	container.add_child(logo_center)
	
	# Title Text
	var title_label: Label = Label.new()
	title_label.text = "Memoirs\nof\nTechnoir"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 44)
	title_label.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY)
	title_label.add_theme_constant_override("line_spacing", 4)
	container.add_child(title_label)
	
	# Spacer
	var spacer_mid: Control = Control.new()
	spacer_mid.custom_minimum_size = Vector2(0, 40)
	container.add_child(spacer_mid)
	
	# Start Button
	var btn_center: CenterContainer = CenterContainer.new()
	var start_btn: Button = Button.new()
	start_btn.text = "Start"
	start_btn.custom_minimum_size = Vector2(220, 60)
	UIStyleHelper.style_button(start_btn, true)
	start_btn.pressed.connect(_on_start_pressed)
	btn_center.add_child(start_btn)
	container.add_child(btn_center)
	
	# Footer Text
	var footer: Label = Label.new()
	footer.text = "still in development\nMemoirs of Technoir 2026"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color("5c6270"))
	footer.set_anchors_preset(PRESET_BOTTOM_WIDE)
	footer.position.y = -60
	add_child(footer)

func _on_start_pressed() -> void:
	start_pressed.emit()
	GameManager.change_state(GameManager.State.HOME_SCREEN)
