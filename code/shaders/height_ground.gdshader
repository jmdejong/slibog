shader_type spatial;

// This is a very simple shader for a low-poly coloured visual, without textures

#include "res://addons/zylann.hterrain/shaders/include/heightmap.gdshaderinc"

const float TRIHEIGHT = 0.866; // sqrt(3) / 2

uniform sampler2D u_terrain_heightmap;
uniform sampler2D u_terrain_normalmap;
// I had to remove `hint_albedo` from colormap in Godot 3 because it makes sRGB conversion kick in,
// which snowballs to black when doing GPU painting on that texture...
uniform sampler2D u_terrain_colormap;// : hint_albedo;
uniform mat4 u_terrain_inverse_transform;
uniform mat3 u_terrain_normal_basis;

uniform float u_specular = 0.5;
varying flat vec4 v_tint;

uniform sampler2D grass_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler3D rock_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform int tex_size = 64;
uniform float pixel_size = 0.25;
uniform float max_y_floor = 0.707;
uniform vec3 map_scale;

varying vec3 world_normal;
varying vec3 world_position;


vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	// Had to negate Z because it comes from Y in the normal map,
	// and OpenGL-style normal maps are Y-up.
	n.z *= -1.0;
	return n;
}

vec2 uv_at(vec3 pos, mat4 model_matrix) {
	vec2 cell_coords = (u_terrain_inverse_transform * model_matrix * vec4(pos, 1)).xz;
	// Must add a half-offset so that we sample the center of pixels,
	// otherwise bilinear filtering of the textures will give us mixed results (#183)
	cell_coords += vec2(0.5);

	// Normalized UV
	return cell_coords / vec2(textureSize(u_terrain_heightmap, 0));
}

float height_at(vec3 pos, mat4 model_matrix) {
	return sample_heightmap(u_terrain_heightmap, uv_at(pos, model_matrix));
}

void vertex() {

	// Normalized UV
	UV = uv_at(VERTEX, MODEL_MATRIX);

	// Height displacement
	float h = sample_heightmap(u_terrain_heightmap, UV);
	VERTEX.y = h;

	//// Putting this in vertex saves 2 fetches from the fragment shader,
	//// which is good for performance at a negligible quality cost,
	//// provided that geometry is a regular grid that decimates with LOD.
	//// (downside is LOD will also decimate tint and splat, but it's not bad overall)
	//v_tint = texture(u_terrain_colormap, UV);

	// Need to use u_terrain_normal_basis to handle scaling.
	//NORMAL = u_terrain_normal_basis * unpack_normal(texture(u_terrain_normalmap, UV));
	NORMAL = -normalize(cross(
		vec3(0.1, height_at(VERTEX + vec3(0.1, 0, 0), MODEL_MATRIX)-h, 0),
		vec3(0, height_at(VERTEX + vec3(0, 0, 0.1), MODEL_MATRIX)-h, 0.1)
	));
	
	world_position = VERTEX * map_scale;
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
}

void fragment() {
	//if (v_tint.a < 0.5) {
		//// TODO Add option to use vertex discarding instead, using NaNs
		//discard;
	//}

	vec3 terrain_normal_world =
		u_terrain_normal_basis * unpack_normal(texture(u_terrain_normalmap, UV));
	terrain_normal_world = normalize(terrain_normal_world);

	//ALBEDO = v_tint.rgb;
	
	vec3 p = world_position / pixel_size;
	
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
	//NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
	vec3 tex_coord = vec3(texelpos(pp)) / float(tex_size);
	//float lod = 1.0/FRAGCOORD.z/pixel_size/max(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y);
	if ((INV_VIEW_MATRIX * vec4(NORMAL, 0)).y > max_y_floor) {
		//ALBEDO = texelFetch(tex, tc % tex_size, lod).xyz;
		ALBEDO = texture(grass_tex, tex_coord.xz).xyz;
		//ALBEDO = textureLod(tex, tex_coord, lod).xyz;
	} else {
		//ALBEDO = texelFetch(wall_tex, tc % tex_size, lod).xyz;
		//ALBEDO = texture(wall_tex, vec2(tex_coord.x + tex_coord.z, tex_coord.y)).xyz;
		ALBEDO = texture(rock_tex, tex_coord).xyz;
		//ALBEDO = textureLod(wall_tex, tex_coord, lod).xyz;
	}
	ROUGHNESS = 1.0;
	SPECULAR = u_specular;
}
