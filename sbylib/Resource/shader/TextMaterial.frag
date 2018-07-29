#vertex Proj

require UV as vec2 uv;
uniform sampler2D tex;
uniform vec4[256] textColors;
uniform float[256] charWidths;

vec4 calcColor() {
    float x = uv.x;
    for (int i = 0; i < 256; i++) {
        if (x < charWidths[i]) return textColors[i];
        x -= charWidths[i];
    }
    return vec4(1);
}

void main() {
    float po = texture(tex, vec2(uv.x, 1-uv.y)).r;
    fragColor = mix(vec4(0), calcColor(), po);
}
