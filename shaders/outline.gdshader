shader_type spatial;
render_mode cull_front, unshaded, depth_draw_always;

// Memoirs of Technoir - Silhouette Outline Shader
// High-visibility inverted hull compatible with Godot 4 gl_compatibility, mobile, and web.

uniform vec4 outline_color : source_color = vec4(0.98, 0.82, 0.25, 1.0);
uniform float outline_width : hint_range(0.0, 20.0, 0.1) = 4.5;
uniform bool is_active = true;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.5;

void vertex() {
	if (is_active && outline_width > 0.0) {
		// Calculate camera distance for consistent screen-space thickness
		float dist = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);
		float scale = clamp(dist * 0.0025, 0.001, 0.015);
		VERTEX += NORMAL * (outline_width * scale);
	}
}

void fragment() {
	if (!is_active) {
		discard;
	}
	float pulse = 0.92 + 0.08 * sin(TIME * pulse_speed);
	ALBEDO = outline_color.rgb * pulse;
	ALPHA = outline_color.a;
}
