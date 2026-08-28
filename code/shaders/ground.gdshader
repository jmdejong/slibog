shader_type spatial;

render_mode specular_disabled, diffuse_lambert;

uniform sampler2D tex : source_color, filter_nearest_mipmap;
uniform sampler2D wall_tex : source_color, filter_nearest_mipmap;
uniform int tex_size = 128;
uniform float pixel_size = 0.5;
uniform float max_y_floor = 0.707;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = VERTEX;
	world_normal = NORMAL;
}

float hash1(ivec2 t) {
	return float(abs(t.x * 123459 + t.y * 234567 + 543) % 100) / 100.0;
}
float hash2(ivec2 t) {
	return float(abs(t.x * 987653 + t.y * 754215 + 129) % 100) / 100.0;
}

vec2 texelpos(ivec2 texel) {
	return vec2(
		float(texel.x) + (hash1(texel) - 0.5)/2.0,
		float(texel.y) + (hash2(texel) - 0.5)/2.0
	);
}

void fragment() {
	vec2 p = world_position.xz / pixel_size;
	ivec2 pf = ivec2(floor(p));
	ivec2 pc = pf + ivec2(1, 1);//ivec2(ceil(p));
	ivec2 pcf = pf + ivec2(1, 0);//ivec2(int(ceil(p.x)), int(floor(p.y)));
	ivec2 pfc = pf + ivec2(0, 1);//ivec2(int(floor(p.x)), int(ceil(p.y)));
	ivec2 corners[4] = { pf, pcf, pfc, pc };
	
	float distances[4];
	//float min_distance = 999999.0;
	for (int i=0; i<4; ++i) {
		float d = distance(texelpos(corners[i]), p);
		//float min_distance = min(d, min_distance);
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
	t += int(floor(world_position.y / pixel_size));
	//ALBEDO = texelFetch(tex, t % tex_size, 0).xyz;
	vec2 tex_coord = vec2(t)/float(tex_size);
	if (normalize(world_normal).y > max_y_floor) {
		ALBEDO = texture(tex, tex_coord).xyz;
	} else {
		ALBEDO = texture(wall_tex, tex_coord).xyz;
	}
	//if ((t.x + t.y)%2 == 0) {
		//ALBEDO = vec3(0, 0, 0);
	//} else {
		//ALBEDO = vec3(1, 1, 1);
	//}
	//ALBEDO = vec3(p, 0);
	//ALBEDO = vec3(distance(p, vec2(pcf)), 0, 0);
	//ALBEDO = vec3(vec2(pc) - p, 0);
	//float c = distance(vec2(t), p);
	//ALBEDO = vec3(c, c, c);
	//ALBEDO = vec3(
		//float(abs(pf.x * 1234547 + pf.y * 32432401 + 2409587)%200)/200.0,
		//float(abs(pf.x * 34823181 + pf.y * 6187137 + 317878)%200)/200.0,
		//float(abs(pf.x * 84317105 + pf.y * 1804877 + 12134870)%200)/200.0
	//);
}
