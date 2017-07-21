#vertex Proj

require UV as vec2 uv;
uniform sampler2D tex;
uniform vec4 color;

void main() {
    float po = texture(tex, uv).r;
    if (po == 0) discard;
    fragColor = color;
}