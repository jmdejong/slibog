shader_type spatial;

render_mode world_vertex_coords, specular_disabled, diffuse_lambert;

uniform sampler2D tex : source_color, filter_nearest_mipmap;
uniform int tex_size = 128;
uniform float pixel_size = 0.5;
varying vec3 world_position;

void vertex() {
	world_position = VERTEX;
}

vec2 texelpos(ivec2 texel) {
	return vec2(
		float(texel.x) + float((texel.x * 123459 + texel.y * 234567 + 543) % 100) / 200.0 - 0.25,
		float(texel.y) + float((texel.x * 987653 + texel.y * 754215 + 129) % 100) / 200.0 - 0.25
	);
}

void fragment() {
	vec2 p = world_position.xz / pixel_size;
	ivec2 pf = ivec2(floor(p));
	ivec2 pc = ivec2(ceil(p));
	ivec2 corners[4] = { pf, ivec2(pc.x, pf.y), ivec2(pf.x, pc.y), pc };
	
	float distances[4];
	float min_distance = 999999.0;
	for (int i=0; i<4; ++i) {
		float d = distance(texelpos(corners[i]), p);
		float min_distance = min(d, min_distance);
		distances[i] = d;
	}
	ivec2 t = distances[0] < distances[1] ? (
		distances[2] < distances[3] ? (
			distances[0] < distances[2] ? corners[0] : corners[2]
		) : (
			distances[0] < distances[3] ? corners[0] : corners[3])
	) : (
		distances[2] < distances[3] ? (
			distances[1] < distances[2] ? corners[1] : corners[2]
		) : (
			distances[1] < distances[3] ? corners[1] : corners[3]
		)
	);
	//ALBEDO = texelFetch(tex, t % tex_size, 0).xyz;
	ALBEDO = texture(tex, vec2(t)/float(tex_size)).xyz;
}
