class_name ChapterSelect
extends Control

## ChapterSelect
## Swipeable chapter selection carousel matching Memoirs of Technoir visual aesthetics.
## Chapters 1 & 2 are fully playable; Chapters 3-5 are locked with vignette darkening shaders.

signal chapter_selected(chapter_data: ChapterData)

const CARD_WIDTH: float = 300.0
const CARD_HEIGHT: float = 430.0
const CARD_SPACING: float = 340.0
const SWIPE_THRESHOLD: float = 45.0

var CHAPTERS: Array[Dictionary] = [
	{
		"number": 1,
		"num_str": "01",
		"title": "Chapter 1 - The Voicemail",
		"subtitle": "where the Voice Lingers",
		"device": "Vintage Cassette Recorder (1979)",
		"image": "res://assets/images/chapter1_recorder.jpg",
		"resource_path": "res://resources/chapters/Chapter1.tres",
		"unlocked": true
	},
	{
		"number": 2,
		"num_str": "02",
		"title": "Chapter 2 - Midnight Breeze",
		"subtitle": "where the Silence Lives",
		"device": "Desk Fan (1978)",
		"image": "res://assets/images/chapter2_fan.jpg",
		"resource_path": "res://resources/chapters/Chapter2.tres",
		"unlocked": true
	},
	{
		"number": 3,
		"num_str": "03",
		"title": "Chapter 3 - Ghost in Phosphor",
		"subtitle": "forgotten frequencies",
		"device": "Portable CRT Monitor (1983)",
		"image": "res://assets/images/chapter3_tv.jpg",
		"resource_path": "",
		"unlocked": false
	},
	{
		"number": 4,
		"num_str": "04",
		"title": "Chapter 4 - Shortwave Echoes",
		"subtitle": "voices in the static",
		"device": "Vacuum Tube Radio (1975)",
		"image": "res://assets/images/chapter4_radio.jpg",
		"resource_path": "",
		"unlocked": false
	},
	{
		"number": 5,
		"num_str": "05",
		"title": "Chapter 5 - Neon Resonator",
		"subtitle": "synthesized dreams",
		"device": "Analog Synthesizer (1982)",
		"image": "res://assets/images/chapter5_synth.jpg",
		"resource_path": "",
		"unlocked": false
	}
]

var current_index: int = 0
var carousel_container: Control
var card_nodes: Array[Control] = []
var dot_nodes: Array[Panel] = []
var action_button: Button

# Touch / Drag tracking
var is_dragging: bool = false
var drag_start_x: float = 0.0
var drag_current_x: float = 0.0
var container_base_x: float = 0.0
var active_tween: Tween

func _ready() -> void:
	_setup_ui()
	_update_carousel(false)

func _setup_ui() -> void:
	# Backdrop
	var bg: ColorRect = ColorRect.new()
	bg.color = UIStyleHelper.COLOR_BG_NIGHT
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# Top Nav Bar
	var nav_bar: TopNavBar = TopNavBar.new()
	nav_bar.set_anchors_preset(PRESET_TOP_WIDE)
	nav_bar.back_pressed.connect(func(): GameManager.change_state(GameManager.State.HOME_SCREEN))
	add_child(nav_bar)
	
	# Carousel Viewport Area (clips or centers cards)
	var carousel_area: Control = Control.new()
	carousel_area.set_anchors_preset(PRESET_FULL_RECT)
	carousel_area.offset_top = 80.0
	carousel_area.offset_bottom = -160.0
	carousel_area.mouse_filter = Control.MOUSE_FILTER_PASS
	carousel_area.gui_input.connect(_on_carousel_input)
	add_child(carousel_area)
	
	carousel_container = Control.new()
	carousel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	carousel_area.add_child(carousel_container)
	
	# Build Cards
	var screen_width: float = 412.0
	var center_x: float = screen_width * 0.5
	var center_y: float = 230.0
	
	for i in range(CHAPTERS.size()):
		var data: Dictionary = CHAPTERS[i]
		var card: Control = _create_chapter_card(i, data)
		card.position = Vector2(center_x + i * CARD_SPACING - CARD_WIDTH * 0.5, center_y - CARD_HEIGHT * 0.5)
		carousel_container.add_child(card)
		card_nodes.append(card)
	
	# Navigation Chevrons (< and >)
	var left_btn: Button = _create_nav_arrow("<", Vector2(10, 290))
	left_btn.pressed.connect(func(): _navigate_to(current_index - 1))
	add_child(left_btn)
	
	var right_btn: Button = _create_nav_arrow(">", Vector2(366, 290))
	right_btn.pressed.connect(func(): _navigate_to(current_index + 1))
	add_child(right_btn)
	
	# Bottom Controls: Action Button, Dots, Footer
	var bottom_vbox: VBoxContainer = VBoxContainer.new()
	bottom_vbox.set_anchors_preset(PRESET_BOTTOM_WIDE)
	bottom_vbox.offset_top = -160.0
	bottom_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_vbox.add_theme_constant_override("separation", 14)
	add_child(bottom_vbox)
	
	# Start / Locked Button
	var btn_center: CenterContainer = CenterContainer.new()
	action_button = Button.new()
	action_button.custom_minimum_size = Vector2(280, 52)
	action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	action_button.pressed.connect(_on_action_button_pressed)
	btn_center.add_child(action_button)
	bottom_vbox.add_child(btn_center)
	
	# Dots Indicator
	var dots_hbox: HBoxContainer = HBoxContainer.new()
	dots_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	dots_hbox.add_theme_constant_override("separation", 10)
	for i in range(CHAPTERS.size()):
		var dot: Panel = Panel.new()
		dot.custom_minimum_size = Vector2(8, 8)
		var d_sb: StyleBoxFlat = StyleBoxFlat.new()
		d_sb.bg_color = Color("4d5466")
		d_sb.set_corner_radius_all(4)
		dot.add_theme_stylebox_override("panel", d_sb)
		dots_hbox.add_child(dot)
		dot_nodes.append(dot)
	bottom_vbox.add_child(dots_hbox)
	
	# Footer Text
	var footer: Label = Label.new()
	footer.text = "Swipe left / right to choose case • Memoirs of Technoir"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("5c6270"))
	bottom_vbox.add_child(footer)

func _create_chapter_card(idx: int, data: Dictionary) -> Control:
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_panel.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var is_unlocked: bool = data["unlocked"]
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color("1e2230") if is_unlocked else Color("141722")
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY if is_unlocked else Color("32394a")
	sb.set_corner_radius_all(28)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 12
	card_panel.add_theme_stylebox_override("panel", sb)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Card Top Bar: Chapter Number & Status Tag
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_theme_constant_override("separation", 120)
	
	var num_label: Label = Label.new()
	num_label.text = data["num_str"]
	num_label.add_theme_font_size_override("font_size", 30)
	num_label.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY if is_unlocked else Color("5c6270"))
	top_hbox.add_child(num_label)
	
	var status_label: Label = Label.new()
	status_label.text = "READY" if is_unlocked else "LOCKED"
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("7ec89e") if is_unlocked else Color("888f9e"))
	top_hbox.add_child(status_label)
	vbox.add_child(top_hbox)
	
	# Card Image Preview Frame
	var preview_panel: PanelContainer = PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(250, 200)
	var psb: StyleBoxFlat = StyleBoxFlat.new()
	psb.bg_color = Color("0a0c12")
	psb.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY if is_unlocked else Color("2c3342")
	psb.border_width_left = 1
	psb.border_width_right = 1
	psb.border_width_top = 1
	psb.border_width_bottom = 1
	psb.set_corner_radius_all(18)
	preview_panel.add_theme_stylebox_override("panel", psb)
	
	# Texture image
	var img_tex: TextureRect = TextureRect.new()
	img_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img_tex.custom_minimum_size = Vector2(250, 200)
	
	if ResourceLoader.exists(data["image"]):
		img_tex.texture = load(data["image"])
	
	# If locked, apply vignette darkening shader
	if not is_unlocked:
		var locked_mat: ShaderMaterial = ShaderMaterial.new()
		locked_mat.shader = load("res://shaders/locked_card.gdshader")
		locked_mat.set_shader_parameter("dark_color", Color(0.04, 0.06, 0.10, 0.85))
		locked_mat.set_shader_parameter("desaturation", 0.90)
		locked_mat.set_shader_parameter("vignette_strength", 1.2)
		img_tex.material = locked_mat
	
	preview_panel.add_child(img_tex)
	
	# If locked, show padlock icon in center
	if not is_unlocked:
		var lock_center: CenterContainer = CenterContainer.new()
		lock_center.custom_minimum_size = Vector2(250, 200)
		var lock_rect: TextureRect = TextureRect.new()
		lock_rect.custom_minimum_size = Vector2(48, 48)
		lock_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists("res://assets/icons/lock.svg"):
			lock_rect.texture = load("res://assets/icons/lock.svg")
		lock_rect.modulate = Color(1.0, 0.85, 0.5, 0.9)
		lock_center.add_child(lock_rect)
		preview_panel.add_child(lock_center)
	
	vbox.add_child(preview_panel)
	
	# Device Name & Subtitle
	var title_lbl: Label = Label.new()
	title_lbl.text = data["device"]
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", UIStyleHelper.COLOR_TEXT_CREAM if is_unlocked else Color("888f9e"))
	vbox.add_child(title_lbl)
	
	var sub_lbl: Label = Label.new()
	sub_lbl.text = data["subtitle"]
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY if is_unlocked else Color("5c6270"))
	vbox.add_child(sub_lbl)
	
	# Wooden workbench accent bar
	var wood_bar: ColorRect = ColorRect.new()
	wood_bar.color = Color("3d2a1d") if is_unlocked else Color("221a15")
	wood_bar.custom_minimum_size = Vector2(240, 8)
	var wood_center: CenterContainer = CenterContainer.new()
	wood_center.add_child(wood_bar)
	vbox.add_child(wood_center)
	
	card_panel.add_child(vbox)
	
	# Tapping card navigates to it or starts it
	card_panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if current_index == idx:
				if is_unlocked:
					_on_action_button_pressed()
			else:
				_navigate_to(idx)
	)
	
	return card_panel

func _create_nav_arrow(arrow_text: String, pos: Vector2) -> Button:
	var btn: Button = Button.new()
	btn.text = arrow_text
	btn.position = pos
	btn.custom_minimum_size = Vector2(36, 44)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.12, 0.18, 0.75)
	sb.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(18)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY)
	btn.add_theme_font_size_override("font_size", 20)
	return btn

func _on_carousel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_x = event.position.x
				drag_current_x = drag_start_x
				container_base_x = carousel_container.position.x
				if active_tween and active_tween.is_valid():
					active_tween.kill()
			else:
				if is_dragging:
					is_dragging = false
					var diff: float = drag_current_x - drag_start_x
					if diff < -SWIPE_THRESHOLD and current_index < CHAPTERS.size() - 1:
						_navigate_to(current_index + 1)
					elif diff > SWIPE_THRESHOLD and current_index > 0:
						_navigate_to(current_index - 1)
					else:
						_navigate_to(current_index)
	elif event is InputEventMouseMotion and is_dragging:
		drag_current_x = event.position.x
		var delta_drag: float = drag_current_x - drag_start_x
		carousel_container.position.x = container_base_x + delta_drag
	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_x = event.position.x
			drag_current_x = drag_start_x
			container_base_x = carousel_container.position.x
			if active_tween and active_tween.is_valid():
				active_tween.kill()
		else:
			if is_dragging:
				is_dragging = false
				var diff: float = drag_current_x - drag_start_x
				if diff < -SWIPE_THRESHOLD and current_index < CHAPTERS.size() - 1:
					_navigate_to(current_index + 1)
				elif diff > SWIPE_THRESHOLD and current_index > 0:
					_navigate_to(current_index - 1)
				else:
					_navigate_to(current_index)
	elif event is InputEventScreenDrag and is_dragging:
		drag_current_x = event.position.x
		var delta_drag: float = drag_current_x - drag_start_x
		carousel_container.position.x = container_base_x + delta_drag

func _navigate_to(index: int) -> void:
	current_index = clamp(index, 0, CHAPTERS.size() - 1)
	_update_carousel(true)

func _update_carousel(animate: bool) -> void:
	var target_x: float = -current_index * CARD_SPACING
	
	if animate:
		if active_tween and active_tween.is_valid():
			active_tween.kill()
		active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(carousel_container, "position:x", target_x, 0.3)
	else:
		carousel_container.position.x = target_x
	
	# Scale active card vs inactive cards
	for i in range(card_nodes.size()):
		var card: Control = card_nodes[i]
		var is_active: bool = (i == current_index)
		var target_scale: Vector2 = Vector2(1.0, 1.0) if is_active else Vector2(0.92, 0.92)
		var target_modulate: Color = Color.WHITE if is_active else Color(0.65, 0.65, 0.75, 0.8)
		if animate:
			var tw: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(card, "scale", target_scale, 0.25)
			tw.parallel().tween_property(card, "modulate", target_modulate, 0.25)
		else:
			card.scale = target_scale
			card.modulate = target_modulate
	
	# Update Dots
	for i in range(dot_nodes.size()):
		var dot: Panel = dot_nodes[i]
		var is_active: bool = (i == current_index)
		var d_sb: StyleBoxFlat = StyleBoxFlat.new()
		d_sb.set_corner_radius_all(4)
		if is_active:
			dot.custom_minimum_size = Vector2(24, 8)
			d_sb.bg_color = UIStyleHelper.COLOR_GOLD_PRIMARY
		else:
			dot.custom_minimum_size = Vector2(8, 8)
			d_sb.bg_color = Color("4d5466")
		dot.add_theme_stylebox_override("panel", d_sb)
	
	# Update Action Button
	var active_data: Dictionary = CHAPTERS[current_index]
	if active_data["unlocked"]:
		action_button.text = "Start " + active_data["title"]
		action_button.disabled = false
		UIStyleHelper.style_button(action_button, true)
	else:
		action_button.text = "🔒 Locked Case (Coming Soon)"
		action_button.disabled = true
		var dis_sb: StyleBoxFlat = StyleBoxFlat.new()
		dis_sb.bg_color = Color("232733")
		dis_sb.border_color = Color("383e4d")
		dis_sb.border_width_left = 1
		dis_sb.border_width_right = 1
		dis_sb.border_width_top = 1
		dis_sb.border_width_bottom = 1
		dis_sb.set_corner_radius_all(26)
		action_button.add_theme_stylebox_override("disabled", dis_sb)
		action_button.add_theme_color_override("font_disabled_color", Color("5c6270"))

func _on_action_button_pressed() -> void:
	var active_data: Dictionary = CHAPTERS[current_index]
	if not active_data["unlocked"]:
		return
	
	var res_path: String = active_data["resource_path"]
	if ResourceLoader.exists(res_path):
		var ch_data: ChapterData = load(res_path)
		chapter_selected.emit(ch_data)
		GameManager.load_chapter(ch_data)
