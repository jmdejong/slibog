shader_type canvas_item;

uniform float faded = 0.0;

void fragment() {
	float dc = length(UV - vec2(0.5, 0.5)) + (faded - 0.5)*2.0;
	COLOR = vec4(0, 0, 0, dc);
}
