shader_type canvas_item;

// Memoirs of Technoir - Locked Project Card Vignette & Darkening Shader
uniform vec4 dark_color : source_color = vec4(0.06, 0.08, 0.12, 0.82);
uniform float desaturation : hint_range(0.0, 1.0) = 0.85;
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 col = COLOR;
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	col.rgb = mix(col.rgb, vec3(gray), desaturation);
	col.rgb = mix(col.rgb, dark_color.rgb, dark_color.a);
	
	vec2 uv = UV - 0.5;
	float dist = length(uv);
	col.rgb *= clamp(1.0 - dist * vignette_strength, 0.3, 1.0);
	
	COLOR = col;
}
