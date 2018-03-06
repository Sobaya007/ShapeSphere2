#vertex Proj

require UV as vec2 uv;
uniform sampler2D tex;
uniform vec4 color;
uniform vec4 backColor;

void main() {
    float po = texture(tex, vec2(uv.x, 1-uv.y)).r;
    fragColor = mix(backColor, color, po);
}
