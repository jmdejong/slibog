shader_type canvas_item;

uniform float faded = 0.0;
uniform sampler3D noise3;

void fragment() {
	float centerdist = length(UV - vec2(0.5, 0.5)) * 1.414; // [0 : 1]
	float blobs = texture(noise3, vec3(UV, faded)).r; // [0: 1]
	float dc = centerdist*0.6 + blobs*0.4 + faded * 2.0 - 1.0;
	COLOR = vec4(0, 0, 0, dc);
}
