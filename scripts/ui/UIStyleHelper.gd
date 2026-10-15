class_name UIStyleHelper
extends RefCounted

## UIStyleHelper
## Centralized styling matching Memoirs of Technoir Figma design system.
## Provides reusable StyleBoxFlat presets, color tokens, and button themes.

# Color Tokens
const COLOR_GOLD_PRIMARY: Color = Color("b8861e")
const COLOR_GOLD_HOVER: Color = Color("cf9723")
const COLOR_GOLD_PRESSED: Color = Color("9c7117")

const COLOR_SLATE_DARK: Color = Color("383b3d")
const COLOR_SLATE_HOVER: Color = Color("4a4e50")
const COLOR_SLATE_PRESSED: Color = Color("2d2f30")

const COLOR_BG_NIGHT: Color = Color("10131c")
const COLOR_BG_CARD: Color = Color("1c202c", 0.92)
const COLOR_BG_FROSTED: Color = Color("232734", 0.88)
const COLOR_BORDER_SUBTLE: Color = Color("3a4052", 0.6)

const COLOR_TEXT_CREAM: Color = Color("f5eedc")
const COLOR_TEXT_MUTED: Color = Color("8c94a6")

static func create_gold_button_style(is_hover: bool = false, is_pressed: bool = false) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	if is_pressed:
		sb.bg_color = COLOR_GOLD_PRESSED
	elif is_hover:
		sb.bg_color = COLOR_GOLD_HOVER
	else:
		sb.bg_color = COLOR_GOLD_PRIMARY
		
	sb.corner_radius_top_left = 18
	sb.corner_radius_top_right = 18
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.shadow_color = Color(0, 0, 0, 0.25)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 2)
	return sb

static func create_slate_button_style(is_hover: bool = false, is_pressed: bool = false) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	if is_pressed:
		sb.bg_color = COLOR_SLATE_PRESSED
	elif is_hover:
		sb.bg_color = COLOR_SLATE_HOVER
	else:
		sb.bg_color = COLOR_SLATE_DARK
		
	sb.corner_radius_top_left = 18
	sb.corner_radius_top_right = 18
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.border_color = Color("525659")
	return sb

static func create_card_panel_style() -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = COLOR_BG_CARD
	sb.corner_radius_top_left = 22
	sb.corner_radius_top_right = 22
	sb.corner_radius_bottom_left = 22
	sb.corner_radius_bottom_right = 22
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.border_color = COLOR_BORDER_SUBTLE
	sb.shadow_color = Color(0, 0, 0, 0.4)
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 4)
	return sb

static func style_button(btn: Button, is_gold: bool = true) -> void:
	if is_gold:
		btn.add_theme_stylebox_override("normal", create_gold_button_style(false, false))
		btn.add_theme_stylebox_override("hover", create_gold_button_style(true, false))
		btn.add_theme_stylebox_override("pressed", create_gold_button_style(false, true))
		btn.add_theme_stylebox_override("focus", create_gold_button_style(false, false))
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color("fffdf0"))
		btn.add_theme_color_override("font_pressed_color", Color("ffe082"))
		btn.add_theme_font_size_override("font_size", 20)
	else:
		btn.add_theme_stylebox_override("normal", create_slate_button_style(false, false))
		btn.add_theme_stylebox_override("hover", create_slate_button_style(true, false))
		btn.add_theme_stylebox_override("pressed", create_slate_button_style(false, true))
		btn.add_theme_stylebox_override("focus", create_slate_button_style(false, false))
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color("f0f2f5"))
		btn.add_theme_color_override("font_pressed_color", Color("cfd4dc"))
		btn.add_theme_font_size_override("font_size", 20)

static func create_icon_button_style(is_hover: bool = false, is_pressed: bool = false) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	if is_pressed:
		sb.bg_color = Color("1a1e29")
		sb.border_color = COLOR_GOLD_PRESSED
	elif is_hover:
		sb.bg_color = Color("2e3446")
		sb.border_color = COLOR_GOLD_PRIMARY
	else:
		sb.bg_color = Color("222634", 0.9)
		sb.border_color = Color("3e465a", 0.7)
		
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if is_hover:
		sb.shadow_color = Color("bb8b24", 0.3)
		sb.shadow_size = 6
	return sb

static func style_icon_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", create_icon_button_style(false, false))
	btn.add_theme_stylebox_override("hover", create_icon_button_style(true, false))
	btn.add_theme_stylebox_override("pressed", create_icon_button_style(false, true))
	btn.add_theme_stylebox_override("focus", create_icon_button_style(true, false))
	btn.add_theme_color_override("font_color", Color("dbe0ea"))
	btn.add_theme_color_override("font_hover_color", Color("ffd54f"))
	btn.add_theme_color_override("font_pressed_color", Color("e0a526"))
