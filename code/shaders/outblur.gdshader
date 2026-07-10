shader_type spatial;
render_mode unshaded;

uniform float inner = 0.1;
uniform float outer = 0.3;

void fragment() {
	float a = dot(NORMAL, VIEW);
	float d = a - 0.6;
	float b = clamp(1.0-d*d*10.0, 0, 1);
	ALPHA = b;
	ALBEDO = vec3(1, 1, 1);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
