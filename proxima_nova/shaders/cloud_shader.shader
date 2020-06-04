shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D worley;
uniform sampler2D perlin;
uniform sampler2D blue;

uniform float amp = 2.0;
uniform bool cast_shadow = false;

uniform float cloud_shift = 0.01;
uniform float global_transparency = 0.75;

vec3 get_noise_octaves(sampler2D noise, vec2 base_uv){
	vec4 oct_1 = textureLod(noise, base_uv, 0.0);
	vec4 oct_2 = textureLod(noise, base_uv / 2.0, 1.0);
	vec4 oct_3 = textureLod(noise, base_uv / 4.0, 2.0);
	return vec3(oct_1.x, oct_2.y, oct_3.z);
}

vec3 get_mixed_noise(vec3 a, vec3 b, vec3 c){
	float noise_a = (a.x + a.y * 0.5 + a.z * 0.25) / 1.75;
	float noise_b = (b.x + b.y * 0.5 + b.z * 0.25) / 1.75;
	float noise_c = (c.x + c.y * 0.5 + c.z * 0.25) / 1.75;
	
	return vec3(noise_a + (noise_b / 2.0) + (noise_c / 4.0)) / 1.75;
}

void vertex(){
	
	
	vec3 mixed_worley = get_noise_octaves(worley, UV+(TIME*cloud_shift));
	vec3 mixed_perlin = get_noise_octaves(perlin, UV+(TIME*cloud_shift));
	vec3 mixed_blue = get_noise_octaves(blue, UV/8.0+(TIME*cloud_shift));
	
	vec3 albedo = clamp(get_mixed_noise(mixed_worley, mixed_perlin, mixed_blue), 0.0, 1.0);
	float intensity_val = (albedo.x+albedo.y+albedo.z) / 3.0;
	VERTEX += (NORMAL * intensity_val * amp);
}

void fragment(){
	
	vec3 mixed_worley = get_noise_octaves(worley, UV+(TIME*cloud_shift));
	vec3 mixed_perlin = get_noise_octaves(perlin, UV+(TIME*cloud_shift));
	vec3 mixed_blue = get_noise_octaves(blue, UV/8.0+(TIME*cloud_shift));
	
	vec3 albedo = get_mixed_noise(mixed_worley, mixed_perlin, mixed_blue) / 3.0;
	
	float intensity_val = pow(clamp(abs((albedo.x+albedo.y+albedo.z)),0., 1.), 4);
	
	NORMAL.z *= intensity_val*amp;
	NORMAL = normalize(NORMAL);
	
	ALBEDO = albedo;
	ALPHA = intensity_val;
	
	float base_fade = clamp(pow(NORMAL.z, 8), 0., 1.);
	ALPHA *= smoothstep(0.0, 1.0, base_fade);
	
	ALPHA *= global_transparency;
}

void light(){
	float NdotL = clamp(max(1.0-abs(dot(NORMAL, LIGHT)), 0.), 0.25, 1.0);
//	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	DIFFUSE_LIGHT += (ALBEDO * LIGHT_COLOR) * NdotL * global_transparency;
	if (cast_shadow == true)
		DIFFUSE_LIGHT *= ATTENUATION;
	
}