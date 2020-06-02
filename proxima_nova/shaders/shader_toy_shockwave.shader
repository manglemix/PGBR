shader_type canvas_item;

void fragment() {
	// Sawtooth calc of time
	float offset = (TIME - floor(TIME)) / TIME;
	float time = TIME * offset;
	
	// Wave design params
	vec3 waveParams = vec3(10.0, 8, 0.1 );
	
	// Find coordinate, flexible to different resolutions
	float maxSize = max((1.0 / SCREEN_PIXEL_SIZE).x, (1.0 / SCREEN_PIXEL_SIZE).y);
	vec2 uv = FRAGCOORD.xy / maxSize;
	
	// Find center, flexible to different resolutions
	vec2 center = (1.0 / SCREEN_PIXEL_SIZE).xy / maxSize / 2.;
	
	// Distance to the center
	float dist = distance(uv, center);
	
	// Original color
	vec4 c = texture(TEXTURE, uv);
	
	// Limit to waves
	if (time > 0. && dist <= time + waveParams.z && dist >= time - waveParams.z) {
		// The pixel offset distance based on the input parameters
		float diff = (dist - time);
		float diffPow = (1.0 - pow(abs(diff * waveParams.x), waveParams.y));
		float diffTime = (diff  * diffPow);
		
		// The direction of the distortion
		vec2 dir = normalize(uv - center);
		
		// Perform the distortion and reduce the effect over time
		uv += ((dir * diffTime) / (time * dist * 80.0));
		
		// Grab color for the new coord
		c = texture(TEXTURE, uv);
		
		// Optionally: Blow out the color for brighter-energy origin
		// c += (c * diffPow) / (time * dist * 40.0);
	}
	COLOR = c;
}