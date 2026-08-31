shader_type spatial;

render_mode specular_disabled, diffuse_lambert;

const float TRIHEIGHT = 0.866; // sqrt(3) / 2

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D wall_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler3D rock_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform int tex_size = 64;
uniform float pixel_size = 0.25;
uniform float max_y_floor = 0.707;
uniform sampler2D height_input;
uniform vec3 area_min;
uniform vec3 area_size;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = VERTEX + NODE_POSITION_WORLD;
	//vec3 map_coordinates = (world_position - area_min) / area_size;
	//VERTEX.y += texture(height_input, map_coordinates.xz).x * area_size.y + area_min.y;
	//world_position = VERTEX + NODE_POSITION_WORLD;
	world_normal = NORMAL;
}

float hash1(ivec3 t) {
	return float(abs(t.x * 123459 + t.y * 234567 + t.z * 14109 + 543) % 128) / 128.0;
}
float hash3(ivec3 t) {
	return float(abs(t.x * 987653 + t.y * 754215 + t.z * 90123 + 129) % 128) / 128.0;
}
float hash2(ivec3 t) {
	return float(abs(t.x * 394579 + t.y * 843951 + t.z * 23057 + 805) % 128) / 128.0;
}

vec3 texelpos(ivec3 texel) {
	vec3 t = vec3(texel);
	return vec3(
		t.x + t.y / 2.0 + t.z / 2.0 + (hash1(texel) - 0.5)/2.0,
		(t.y + t.z / 2.0) * TRIHEIGHT + (hash2(texel) - 0.5)/2.0,
		t.z * TRIHEIGHT + (hash3(texel) - 0.5)/3.0
	);
	//return vec3(
		//t.x + (hash1(texel) - 0.5)/2.0,
		//t.y + (hash2(texel) - 0.5)/2.0,
		//t.z + (hash3(texel) - 0.5)/2.0
	//);
}

void fragment() {
	vec3 p = world_position.xyz / pixel_size;
	
	float vz = p.z / TRIHEIGHT;
	float vy = p.y / TRIHEIGHT - vz / 2.0;
	float vx = p.x - vy / 2.0 - vz / 2.0;
	vec3 v = vec3(vx, vy, vz);
	//vec3 v = p;
	ivec3 pf = ivec3(floor(v));
	vec3 fr = fract(v);
	ivec3 corners[7] = { 
		pf + ivec3(1, 0, 0),
		pf + ivec3(0, 1, 0),
		pf + ivec3(0, 0, 1),
		pf + ivec3(1, 1, 0),
		pf + ivec3(0, 1, 1),
		pf + ivec3(1, 0, 1),
		pf + ivec3(1, 1, 1)
	};
	
	float min_distance = distance(texelpos(pf), p);
	ivec3 pp = pf;
	for (int i=0; i<7; ++i) {
		float d = distance(texelpos(corners[i]), p);
		if (d<min_distance) {
			pp = corners[i];
			min_distance = d;
		}
	}
	//ivec2 tc = ivec2(pp.x, pp.z);
	vec3 tex_coord = vec3(texelpos(pp)) / float(tex_size);
	//float lod = 1.0/FRAGCOORD.z/pixel_size/max(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y);
	if (normalize(world_normal).y > max_y_floor) {
		//ALBEDO = texelFetch(tex, tc % tex_size, lod).xyz;
		ALBEDO = texture(tex, tex_coord.xz).xyz;
		//ALBEDO = textureLod(tex, tex_coord, lod).xyz;
	} else {
		//ALBEDO = texelFetch(wall_tex, tc % tex_size, lod).xyz;
		//ALBEDO = texture(wall_tex, vec2(tex_coord.x + tex_coord.z, tex_coord.y)).xyz;
		ALBEDO = texture(rock_tex, tex_coord).xyz;
		//ALBEDO = textureLod(wall_tex, tex_coord, lod).xyz;
	}
	//if (tc % tex_size == ivec2(tex_size-1, tex_size-1)) {
		//ALBEDO = vec3(0, 0, 1);
	//}
	//if (min_distance < 0.1) {
		//ALBEDO = vec3(0,0,0);
	//}
	//if (fr.x < 0.02 || fr.y < 0.02 || fr.z < 0.02) {
		//ALBEDO += vec3(1, 0, 0) * 0.3;
	//}
}
