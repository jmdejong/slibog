shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_a;
uniform sampler2D noise_b;
uniform sampler2D noise_c;
uniform vec3 blue: source_color;
uniform vec3 white: source_color;


void fragment() {
	vec2 p = vec2(UV.x*3.0, UV.y*100.0);
	//float a = texture(noise_a, vec2(EYEDIR.xy)).x;
	float a = texture(noise_a, p + TIME * vec2(0.003, 0)).x - 0.5;
	float b = texture(noise_b, p + TIME * vec2(0.001, 0)).x - 0.5;
	float c = texture(noise_c, p + TIME * vec2(0.00005, 0)).x * 0.1;
	float cloudy = clamp(a*2.0+b*2.0, 0, 1) + c;

	ALBEDO = mix(blue, white, clamp(cloudy, 0, 1));
	//COLOR = EYEDIR;
}
