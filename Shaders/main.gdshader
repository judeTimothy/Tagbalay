shader_type canvas_item;

// Adjust the distortion amount (positive for barrel/fisheye, negative for pincushion)
uniform float amount : hint_range(-100.0, 100.0) = 10.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    float newAmount = (amount / 100.0) + 1.0;
    vec2 texcoord = SCREEN_UV;
    vec2 kCenter = vec2(0.5);
    vec2 vec = (texcoord - kCenter) / kCenter;
    float vecLength = length(vec);
    float r = pow(min(vecLength, 1.0), newAmount) * max(1.0, vecLength);
    vec2 unit = vec / vecLength;
    texcoord = kCenter + r * unit * kCenter;
    
    COLOR = texture(SCREEN_TEXTURE, texcoord);
}
