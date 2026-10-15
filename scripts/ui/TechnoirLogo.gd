class_name TechnoirLogo
extends Control

## TechnoirLogo
## Renders the official Memoirs of Technoir cassette spool emblem from icon.svg.

@export var logo_color: Color = Color("bb8b24")
@export var custom_icon_path: String = "res://icon.svg"

var _texture_rect: TextureRect

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_setup_texture()

func _setup_texture() -> void:
	var tex: Texture2D = load(custom_icon_path) as Texture2D
	if tex:
		_texture_rect = TextureRect.new()
		_texture_rect.texture = tex
		_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_texture_rect.set_anchors_preset(PRESET_FULL_RECT)
		_texture_rect.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(_texture_rect)
	else:
		queue_redraw()

func _draw() -> void:
	if _texture_rect and _texture_rect.texture:
		return
	# Fallback procedural vector drawing if texture cannot be loaded
	var s: float = minf(size.x, size.y)
	if s <= 0.0:
		return
	var stroke: float = s * 0.075
	var box_rect: Rect2 = Rect2(s * 0.1, s * 0.1, s * 0.55, s * 0.55)
	draw_rect(box_rect, logo_color, true)
	var center_circle: Vector2 = box_rect.get_center()
	draw_circle(center_circle, s * 0.18, Color("10131c"))
	draw_circle(center_circle, s * 0.08, logo_color)
	draw_line(center_circle + Vector2(0, s * 0.18), Vector2(s * 0.72, s * 0.85), logo_color, stroke)
	draw_line(center_circle + Vector2(s * 0.18, 0), Vector2(s * 0.85, s * 0.72), logo_color, stroke)
	var spool_center: Vector2 = Vector2(s * 0.75, s * 0.75)
	draw_circle(spool_center, s * 0.19, logo_color)
	draw_circle(spool_center, s * 0.08, Color("10131c"))
