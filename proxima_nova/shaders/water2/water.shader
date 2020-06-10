shader_type spatial;

uniform float wave_speed = 0.25;
uniform float depthOffset = -0.75;
uniform vec4 wave1 = vec4(0.05, 0.05, 0.15, 0.3);
uniform vec4 wave2 = vec4(0.08, 0.26, 0.30, 0.155);
uniform vec4 wave3 = vec4(0.15, 0.08, 0.25, 0.09);

uniform float foam_level = 0.025f;

uniform vec4 colorDeep : hint_color;
uniform vec4 colorShallow : hint_color;

varying float vertex_height;

varying mat4 inv_mvp;

vec4 wave(vec4 parameter, vec2 position, float time, inout vec3 tangent, inout vec3 binormal)
{
	float wave_steepness = parameter.z;
	float wave_length = parameter.w;

	float k = 2.0 * 3.14159265359 / wave_length;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(parameter.xy);
	float f	 = k * (dot(d, position) - c * time);
	float a = wave_steepness / k;
	
	tangent += normalize(vec3(1.0-d.x * d.x * (wave_steepness * sin(f)), d.x * (wave_steepness * cos(f)), -d.x * d.y * (wave_steepness * sin(f))));
	binormal += normalize(vec3(-d.x * d.y * (wave_steepness * sin(f)), d.y * (wave_steepness * cos(f)), 1.0-d.y * d.y * (wave_steepness * sin(f))));
	
	return vec4(d.x * (a * cos(f)), a * sin(f) * 0.25, d.y * (a * cos(f)), 0.0);
}

void vertex()
{
	float	time = TIME * wave_speed;
	vec4 vertex = vec4(VERTEX, 1.0);
	vec3 vertexPosition = (WORLD_MATRIX * vertex).xyz;
	
	vec3 vertexTangent = vec3(0.0, 0.0, 0.0);
	vec3 vertexBinormal = vec3(0.0, 0.0, 0.0);
	vertex += wave(wave1, vertexPosition.xz, time, vertexTangent, vertexBinormal);
	vertex += wave(wave2, vertexPosition.xz, time, vertexTangent, vertexBinormal);
	vertex += wave(wave3, vertexPosition.xz, time, vertexTangent, vertexBinormal);
	
	TANGENT = vertexTangent;
	BINORMAL = vertexBinormal;
	vec3 vertex_normal = normalize(cross(vertexBinormal, vertexTangent));
	NORMAL = vertex_normal;
	
	VERTEX = vertex.xyz;
	
	inv_mvp = inverse(PROJECTION_MATRIX * MODELVIEW_MATRIX);
}

void fragment()
{
	float depthRaw = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depthRaw + PROJECTION_MATRIX[2][2]);
	
	float depthBlend = exp((depth+VERTEX.z + depthOffset) * -2.0);
	depthBlend = clamp(1.0-depthBlend, 0.0, 1.0);
	float depthBlendPow = clamp(pow(depthBlend, 2.5), 0.0, 1.0);
	
	vec3 screenColor = textureLod(SCREEN_TEXTURE, SCREEN_UV + (NORMAL.xz * 0.02), depthBlendPow * 2.5).rgb;
	vec3 dyeColor = mix(colorShallow.rgb, colorDeep.rgb, depthBlendPow);
	vec3 color = mix(screenColor*dyeColor, dyeColor*0.25, depthBlendPow*0.5);
	
	float foamAmount = max(min(1.0, (foam_level - depth - VERTEX.z) / foam_level), 0.0);
	
	ALBEDO = mix(color, vec3(1.0, 1.0, 1.0), foamAmount);
	SPECULAR = mix(0.2 * depthBlendPow * 0.4, 0.1, foamAmount);
	ROUGHNESS = mix(0.2, 1.0, foamAmount);
}