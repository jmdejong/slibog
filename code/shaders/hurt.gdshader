shader_type canvas_item;

uniform float hurt;
uniform vec3 hurt_color: source_color;


void fragment() {
	
	float centerdist = length(UV - vec2(0.5, 0.5)) * 1.414; // [0 : 1]
	
	COLOR = vec4(hurt_color, centerdist-1.0+hurt);
}
