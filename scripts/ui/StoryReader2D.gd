class_name StoryReader2D
extends Control

## StoryReader2D
## Webtoon comic reader that displays the full dadakan bet.png artwork as a vertical scrolling strip,
## followed by the gold "Start Chapter" continue button matching Figma node 2024:797.

signal enter_workbench_requested()

const COMIC_ART_PATH: String = "res://dadakan bet.png"

var _scroll_container: ScrollContainer
var _vbox: VBoxContainer
var _comic_texture_rect: TextureRect

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Deep night background
	var bg: ColorRect = ColorRect.new()
	bg.color = Color("10131c")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	# ScrollContainer for smooth vertical webtoon panning
	_scroll_container = ScrollContainer.new()
	_scroll_container.set_anchors_preset(PRESET_FULL_RECT)
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(_scroll_container)
	
	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_theme_constant_override("separation", 20)
	_scroll_container.add_child(_vbox)
	
	# Top spacer to give clearance below the fixed top bar
	var top_spacer: Control = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 68)
	_vbox.add_child(top_spacer)
	
	# Full Webtoon Image (dadakan bet.png)
	var comic_tex: Texture2D = load(COMIC_ART_PATH) as Texture2D
	if comic_tex:
		_comic_texture_rect = TextureRect.new()
		_comic_texture_rect.texture = comic_tex
		_comic_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		_comic_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_comic_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_comic_texture_rect.mouse_filter = MOUSE_FILTER_PASS
		var tex_w: float = float(comic_tex.get_width())
		var tex_h: float = float(comic_tex.get_height())
		if tex_w > 0.0:
			var aspect: float = tex_h / tex_w
			_comic_texture_rect.custom_minimum_size = Vector2(412.0, 412.0 * aspect)
		_vbox.add_child(_comic_texture_rect)
	else:
		# Fallback placeholder if image not found
		var missing_lbl: Label = Label.new()
		missing_lbl.text = "Loading Comic Strip..."
		missing_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(missing_lbl)
		
	# Continue Button (matching Figma "Start Chapter" gold button)
	var btn_center: CenterContainer = CenterContainer.new()
	btn_center.custom_minimum_size = Vector2(0, 70)
	var start_btn: Button = Button.new()
	start_btn.text = "Start Chapter"
	start_btn.custom_minimum_size = Vector2(250, 52)
	UIStyleHelper.style_button(start_btn, true)
	start_btn.pressed.connect(_on_continue_pressed)
	btn_center.add_child(start_btn)
	_vbox.add_child(btn_center)
	
	# Clean Footer
	var footer: Label = Label.new()
	footer.text = "still in development\nMemoirs of Technoir 2026"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color("5c6270"))
	_vbox.add_child(footer)
	
	var bottom_spacer: Control = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 40)
	_vbox.add_child(bottom_spacer)
	
	# Fixed Top Nav Bar
	var nav_bar: TopNavBar = TopNavBar.new()
	nav_bar.set_anchors_preset(PRESET_TOP_WIDE)
	nav_bar.back_pressed.connect(func(): GameManager.change_state(GameManager.State.CHAPTER_SELECT))
	add_child(nav_bar)

func _on_continue_pressed() -> void:
	AudioManager.play_click()
	enter_workbench_requested.emit()
	GameManager.enter_workstation()
