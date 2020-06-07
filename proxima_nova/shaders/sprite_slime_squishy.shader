shader_type canvas_item;

uniform float h_stretch: hint_range(-1, 1);

void fragment() {
    vec2 uv = 2.0 * UV - vec2(1.0);
    uv.x *= 2.0;
    
    float f = 1.0 - uv.y * uv.y;
    if (h_stretch >= 0.0) {
        f = sqrt(f) / 2.0;
    }
    uv.x -= uv.x * f * h_stretch;
    
    uv = (uv + vec2(1.0)) / 2.0;
    if (uv.x < 0.0 || uv.x >= 1.0) {
        COLOR = vec4(0.0);
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}