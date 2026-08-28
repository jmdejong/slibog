shader_type sky;

uniform sampler2D noise_a;
uniform sampler2D noise_b;
uniform sampler2D noise_c;
uniform vec3 blue: source_color;
uniform vec3 white: source_color;


void sky() {
	vec2 p = vec2(atan(EYEDIR.z, EYEDIR.x)/PI/2.0, EYEDIR.y);
	//float a = texture(noise_a, vec2(EYEDIR.xy)).x;
	float a = texture(noise_a, p + TIME * vec2(0.005, 0)).x - 0.4;
	float b = texture(noise_b, p + TIME * vec2(0.002, 0)).x - 0.4;
	float c = texture(noise_c, p + TIME * vec2(0.0001, 0)).x * 0.1;
	float cloudy = clamp(a+b, 0, 1) + c;
	
	COLOR = mix(blue, white, clamp(cloudy, 0, 1));
	//COLOR = EYEDIR;
}
