class_name UI_Overlay
extends Control

## UI_Overlay
## Minimalist, decluttered Workstation HUD strictly matching Figma "chapter 1 scene" (node 2024:853).
## Allows direct multi-touch panning and 3D interactions without HUD blockage.

signal story_button_pressed()
signal back_to_chapters_pressed()

var controller: WorkstationController

var _nav_bar: TopNavBar
var _cam_mode_btn: Button
var _cam_reset_btn: Button
var _tool_badge_btn: Button
var _toolbox_popup: PanelContainer
var _toast_banner: PanelContainer
var _toast_label: Label
var _toast_tween: Tween

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_setup_ui()
	ToolBeltManager.tool_changed.connect(_on_tool_changed)
	_update_tool_badge(ToolBeltManager.get_active_tool())

func _setup_ui() -> void:
	# 1. Clean Top Navigation Bar
	_nav_bar = TopNavBar.new()
	_nav_bar.set_anchors_preset(PRESET_TOP_WIDE)
	_nav_bar.mouse_filter = MOUSE_FILTER_IGNORE
	_nav_bar.back_pressed.connect(func(): back_to_chapters_pressed.emit())
	add_child(_nav_bar)

	# 2. Camera Controls Bar (Left side below navbar: Orbit/Pan toggle & Reset)
	_setup_camera_controls()

	# 3. Bottom Equipped Tool Badge (Center bottom)
	_setup_tool_badge()

	# 4. Bottom-Right Floating Buttons (Story Book & Toolbox) matching Figma node 2024:1176
	_setup_floating_action_buttons()

	# 5. Clean Footer matching Figma
	var footer: Label = Label.new()
	footer.text = "Memoirs of Technoir • Chapter Workbench"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color("5c6270", 0.6))
	footer.set_anchors_preset(PRESET_BOTTOM_WIDE)
	footer.position.y = -35
	footer.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(footer)

	# 6. Toolbox Modal Popup
	_setup_toolbox_modal()

	# 7. Notification Toast (Subtle pill notification)
	_setup_toast_banner()

func _setup_camera_controls() -> void:
	var cam_box: VBoxContainer = VBoxContainer.new()
	cam_box.position = Vector2(16, 76)
	cam_box.add_theme_constant_override("separation", 8)
	cam_box.mouse_filter = MOUSE_FILTER_IGNORE
	
	# Mode Toggle Button (Orbit <-> Pan)
	_cam_mode_btn = Button.new()
	_cam_mode_btn.custom_minimum_size = Vector2(92, 36)
	_cam_mode_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_cam_mode_btn.text = "🔄 Orbit"
	_cam_mode_btn.add_theme_font_size_override("font_size", 12)
	UIStyleHelper.style_icon_button(_cam_mode_btn)
	_cam_mode_btn.pressed.connect(_on_toggle_camera_mode)
	cam_box.add_child(_cam_mode_btn)
	
	# Reset Camera Button
	_cam_reset_btn = Button.new()
	_cam_reset_btn.custom_minimum_size = Vector2(92, 36)
	_cam_reset_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_cam_reset_btn.text = "🎯 Reset"
	_cam_reset_btn.add_theme_font_size_override("font_size", 12)
	UIStyleHelper.style_icon_button(_cam_reset_btn)
	_cam_reset_btn.pressed.connect(_on_reset_camera)
	cam_box.add_child(_cam_reset_btn)
	
	add_child(cam_box)

func _setup_tool_badge() -> void:
	var badge_wrap: CenterContainer = CenterContainer.new()
	badge_wrap.set_anchors_preset(PRESET_BOTTOM_WIDE)
	badge_wrap.position.y = -95
	badge_wrap.mouse_filter = MOUSE_FILTER_IGNORE
	
	_tool_badge_btn = Button.new()
	_tool_badge_btn.custom_minimum_size = Vector2(190, 42)
	_tool_badge_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tool_badge_btn.text = "✋ Hand (Tap to Interact)"
	_tool_badge_btn.add_theme_font_size_override("font_size", 12)
	
	var sb_normal: StyleBoxFlat = StyleBoxFlat.new()
	sb_normal.bg_color = Color("1a1e2a", 0.92)
	sb_normal.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	sb_normal.border_width_left = 1
	sb_normal.border_width_right = 1
	sb_normal.border_width_top = 1
	sb_normal.border_width_bottom = 1
	sb_normal.set_corner_radius_all(21)
	sb_normal.shadow_color = Color(0, 0, 0, 0.4)
	sb_normal.shadow_size = 6
	sb_normal.content_margin_left = 16
	sb_normal.content_margin_right = 16
	
	var sb_hover: StyleBoxFlat = sb_normal.duplicate()
	sb_hover.bg_color = Color("282e40")
	sb_hover.border_color = Color("ffd54f")
	
	var sb_pressed: StyleBoxFlat = sb_normal.duplicate()
	sb_pressed.bg_color = Color("141720")
	sb_pressed.border_color = UIStyleHelper.COLOR_GOLD_PRESSED
	
	_tool_badge_btn.add_theme_stylebox_override("normal", sb_normal)
	_tool_badge_btn.add_theme_stylebox_override("hover", sb_hover)
	_tool_badge_btn.add_theme_stylebox_override("pressed", sb_pressed)
	_tool_badge_btn.add_theme_stylebox_override("focus", sb_normal)
	_tool_badge_btn.add_theme_color_override("font_color", UIStyleHelper.COLOR_TEXT_CREAM)
	_tool_badge_btn.add_theme_color_override("font_hover_color", Color("ffd54f"))
	
	_tool_badge_btn.pressed.connect(_toggle_toolbox)
	badge_wrap.add_child(_tool_badge_btn)
	add_child(badge_wrap)

func _setup_floating_action_buttons() -> void:
	var float_box: VBoxContainer = VBoxContainer.new()
	float_box.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	float_box.position = Vector2(-70, -170)
	float_box.add_theme_constant_override("separation", 14)
	float_box.mouse_filter = MOUSE_FILTER_IGNORE
	
	# 1. Comic Story Book Button (circular white button with book icon)
	var story_btn: Button = _create_circular_button("📖")
	story_btn.tooltip_text = "Read Chapter Story"
	story_btn.pressed.connect(func(): story_button_pressed.emit())
	float_box.add_child(story_btn)
	
	# 2. Toolbox Button (circular white button with briefcase icon)
	var toolbox_btn: Button = _create_circular_button("🧰")
	toolbox_btn.tooltip_text = "Open Toolbox"
	toolbox_btn.pressed.connect(_toggle_toolbox)
	float_box.add_child(toolbox_btn)
	
	add_child(float_box)

func _create_circular_button(icon_text: String) -> Button:
	var btn: Button = Button.new()
	btn.text = icon_text
	btn.custom_minimum_size = Vector2(50, 50)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color("f4f6fa") # Clean white matching Figma
	sb.set_corner_radius_all(25)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	
	var sb_hover: StyleBoxFlat = sb.duplicate()
	sb_hover.bg_color = Color("ffffff")
	sb_hover.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	sb_hover.border_width_left = 2
	sb_hover.border_width_right = 2
	sb_hover.border_width_top = 2
	sb_hover.border_width_bottom = 2
	
	var sb_pressed: StyleBoxFlat = sb.duplicate()
	sb_pressed.bg_color = Color("d2d6e0")
	
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("focus", sb_hover)
	btn.add_theme_color_override("font_color", Color("141822"))
	btn.add_theme_font_size_override("font_size", 20)
	return btn

func _setup_toolbox_modal() -> void:
	_toolbox_popup = PanelContainer.new()
	_toolbox_popup.set_anchors_preset(PRESET_CENTER)
	_toolbox_popup.custom_minimum_size = Vector2(340, 240)
	_toolbox_popup.position = Vector2(-170, -120)
	_toolbox_popup.visible = false
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color("1e222e", 0.96)
	sb.set_corner_radius_all(20)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	sb.shadow_color = Color(0, 0, 0, 0.6)
	sb.shadow_size = 24
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	_toolbox_popup.add_theme_stylebox_override("panel", sb)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	
	var top_h: HBoxContainer = HBoxContainer.new()
	var title: Label = Label.new()
	title.text = "WORKBENCH TOOLS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UIStyleHelper.COLOR_GOLD_PRIMARY)
	top_h.add_child(title)
	
	var close_btn: Button = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.pressed.connect(func(): _toolbox_popup.visible = false)
	UIStyleHelper.style_icon_button(close_btn)
	top_h.add_child(close_btn)
	vbox.add_child(top_h)
	
	var tools_hbox: HBoxContainer = HBoxContainer.new()
	tools_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tools_hbox.add_theme_constant_override("separation", 12)
	
	# Option 1: Hand
	var hand_btn: Button = _create_tool_card_button("✋", "Hand", ToolBeltManager.TOOL_HAND)
	tools_hbox.add_child(hand_btn)
	
	# Option 2: Screwdriver
	var screw_btn: Button = _create_tool_card_button("🪛", "Screwdriver", ToolBeltManager.TOOL_SCREWDRIVER)
	tools_hbox.add_child(screw_btn)
	
	# Option 3: Cleaner Brush
	var brush_btn: Button = _create_tool_card_button("🧹", "Brush", ToolBeltManager.TOOL_CLEANER)
	tools_hbox.add_child(brush_btn)
	
	vbox.add_child(tools_hbox)
	_toolbox_popup.add_child(vbox)
	add_child(_toolbox_popup)

func _create_tool_card_button(icon_text: String, label_text: String, tool_id: String) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(88, 110)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color("2a2f3e")
	sb.set_corner_radius_all(14)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.border_color = Color("464f66")
	
	var sb_hover: StyleBoxFlat = sb.duplicate()
	sb_hover.bg_color = Color("383f54")
	sb_hover.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	
	var sb_pressed: StyleBoxFlat = sb.duplicate()
	sb_pressed.bg_color = Color("1e222e")
	sb_pressed.border_color = UIStyleHelper.COLOR_GOLD_PRESSED
	
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("focus", sb_hover)
	btn.text = "%s\n\n%s" % [icon_text, label_text]
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color("f0f2f5"))
	btn.add_theme_color_override("font_hover_color", Color("ffd54f"))
	btn.pressed.connect(func():
		ToolBeltManager.equip_tool(tool_id)
		_toolbox_popup.visible = false
	)
	return btn

func _toggle_toolbox() -> void:
	AudioManager.play_click()
	_toolbox_popup.visible = not _toolbox_popup.visible

func _on_toggle_camera_mode() -> void:
	AudioManager.play_click()
	if controller:
		var mode = controller.toggle_camera_mode()
		if mode == WorkstationController.CameraMode.PAN:
			_cam_mode_btn.text = "✋ Pan"
			show_toast("Camera Mode: PAN (Drag to move workbench)", false)
		else:
			_cam_mode_btn.text = "🔄 Orbit"
			show_toast("Camera Mode: ORBIT (Drag to rotate angle)", false)

func _on_reset_camera() -> void:
	AudioManager.play_click()
	if controller:
		controller.reset_camera()
		show_toast("Camera view centered.", false)

func _on_tool_changed(new_tool_id: String, _old_tool_id: String) -> void:
	_update_tool_badge(new_tool_id)

func _update_tool_badge(tool_id: String) -> void:
	if not _tool_badge_btn:
		return
	match tool_id:
		ToolBeltManager.TOOL_SCREWDRIVER:
			_tool_badge_btn.text = "🪛 Screwdriver (Fasten / Loosen)"
		ToolBeltManager.TOOL_CLEANER:
			_tool_badge_btn.text = "🧹 Cleaning Brush (Remove Grime)"
		_:
			_tool_badge_btn.text = "✋ Hand (Tap to Interact)"

func _setup_toast_banner() -> void:
	_toast_banner = PanelContainer.new()
	_toast_banner.set_anchors_preset(PRESET_TOP_WIDE)
	_toast_banner.position = Vector2(0, -60)
	_toast_banner.custom_minimum_size = Vector2(0, 44)
	_toast_banner.mouse_filter = MOUSE_FILTER_IGNORE
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color("1e222e", 0.95)
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = UIStyleHelper.COLOR_GOLD_PRIMARY
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	_toast_banner.add_theme_stylebox_override("panel", sb)
	
	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 12)
	_toast_label.add_theme_color_override("font_color", Color("f0f2f5"))
	_toast_banner.add_child(_toast_label)
	add_child(_toast_banner)

## Displays animated notification toast for physical blocked states and successes
func show_toast(message: String, is_warning: bool = false) -> void:
	_toast_label.text = message
	var sb: StyleBoxFlat = _toast_banner.get_theme_stylebox("panel") as StyleBoxFlat
	if sb:
		sb.border_color = Color("ef5350") if is_warning else UIStyleHelper.COLOR_GOLD_PRIMARY
		
	if _toast_tween:
		_toast_tween.kill()
		
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast_banner, "position:y", 0.0, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_toast_tween.tween_interval(2.0)
	_toast_tween.tween_property(_toast_banner, "position:y", -60.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
