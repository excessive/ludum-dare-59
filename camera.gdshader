shader_type canvas_item;

uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable;
uniform float glitch = 0.0;
uniform vec3 glitch_color : source_color;

void fragment() {
	float g2 = distance(glitch, 0.5) * 2.0 - 1.0;
	COLOR *= texture(screen_texture, SCREEN_UV + vec2(distance(SCREEN_UV, vec2(0.5)) * glitch, mod(g2, 0.5) * 0.5) * 0.125);
	COLOR.rgb = mix(COLOR.rgb, COLOR.rgb * glitch_color, glitch);
}
