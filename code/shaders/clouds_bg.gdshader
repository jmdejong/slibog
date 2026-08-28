shader_type canvas_item;
uniform sampler2D noise_a: repeat_enable;

varying vec2 p;

void vertex() {
	//p = VERTEX * vec2(0.00006, 0.0002);
}

void fragment() {
	p = vec2(-SCREEN_UV.x, (SCREEN_UV.y-0.5) * SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y) * vec2(0.2, 1.0);
	float c = (texture(noise_a, fract(p + TIME * vec2(0.005, 0))).x - 0.7) * 5.0;
	
	COLOR = vec4(1, 1, 1, clamp(c, 0, 1));
}
