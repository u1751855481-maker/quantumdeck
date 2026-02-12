shader_type canvas_item;

uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 flashed = mix(tex.rgb, vec3(1.0), flash_strength);
	COLOR = vec4(flashed, tex.a) * COLOR;
}
