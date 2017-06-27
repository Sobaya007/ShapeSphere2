#vertex Proj

require Shader Material0;
require Shader Material1;
require UV as vec2 uv;

uniform float size;

void main() {
    vec2 po = mod(uv / (size * 2), vec2(1)) - 0.5;
    if (po.x * po.y > 0) {
        Material0(fragColor);
    } else {
        Material1(fragColor);
    }
}
