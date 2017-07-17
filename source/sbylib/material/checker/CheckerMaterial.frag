#vertex Proj

require Shader Material1;
require Shader Material2;
require UV as vec2 uv;

uniform float size;

void main() {
    vec2 po = mod(uv / (size * 2), vec2(1)) - 0.5;
    if (po.x * po.y > 0) {
        Material1(fragColor);
    } else {
        Material2(fragColor);
    }
}
