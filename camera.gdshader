shader_type canvas_item;

uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable;
uniform sampler2D glitch_afterimage : source_color, repeat_disable, hint_default_black;

uniform float glitch = 0.0;
uniform float barrel: hint_range(-0.5, 0.5, 0.01) = 0.1;
uniform float barrel_adjust: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float chromab: hint_range(0.0, 0.1, 0.001) = 0.0;
uniform vec3 glitch_color : source_color;

void fragment() {
	vec2 uv = SCREEN_UV;
	float g2 = distance(glitch, 0.5) * 2.0 - 1.0;
	vec2 guv = uv + vec2(distance(uv, vec2(0.5)) * glitch, mod(g2, 0.5) * 0.5) * 0.125;
	guv = guv * 2.0 - 1.0;
	guv *= (1.0 - length(guv) * (barrel_adjust + barrel + glitch)) * (1.0 + barrel);
	vec2 guvr = (guv * (1.0 + chromab)) * 0.5 + 0.5;
	vec2 guvg = guv * 0.5 + 0.5;
	vec2 guvb = (guv * (1.0 - chromab * 0.25)) * 0.5 + 0.5;

	vec3 afterimage = vec3(
		textureLod(glitch_afterimage, guvr, 0.0).r,
		textureLod(glitch_afterimage, guvg, 0.0).g,
		textureLod(glitch_afterimage, guvb, 0.0).b
	);
	COLOR.r *= textureLod(screen_texture, guvr, 0.0).r;
	COLOR.g *= textureLod(screen_texture, guvg, 0.0).g;
	COLOR.b *= textureLod(screen_texture, guvb, 0.0).b;
	COLOR.rgb = mix(COLOR.rgb, COLOR.rgb * glitch_color, glitch);
	COLOR.rgb = mix(COLOR.rgb, afterimage, glitch);
}
