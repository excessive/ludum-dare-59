shader_type canvas_item;

uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D glitch_afterimage : source_color, hint_default_black, repeat_disable, filter_linear;

uniform float glitch = 0.0;
uniform float barrel: hint_range(-0.5, 0.5, 0.01) = 0.1;
uniform float barrel_adjust: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float chromab: hint_range(0.0, 0.1, 0.001) = 0.0;
uniform vec3 glitch_color : source_color;

// https://github.com/CptPotato/GodotThings/blob/master/SmoothPixelFiltering/SmoothPixel.shader
vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size) {
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	vec2 uv_pixels = uv / pixel_size;
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	uv = uv_pixels_floor * pixel_size;
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

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
	COLOR.r *= texturePointSmooth(screen_texture, guvr, SCREEN_PIXEL_SIZE).r;
	COLOR.g *= texturePointSmooth(screen_texture, guvg, SCREEN_PIXEL_SIZE).g;
	COLOR.b *= texturePointSmooth(screen_texture, guvb, SCREEN_PIXEL_SIZE).b;
	COLOR.rgb = mix(COLOR.rgb, COLOR.rgb * glitch_color, glitch);
	COLOR.rgb = mix(COLOR.rgb, afterimage, glitch);
}
