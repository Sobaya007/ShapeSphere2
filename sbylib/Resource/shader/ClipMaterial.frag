#vertex Proj

require Shader Material1;
require Shader Material2;
require UV as vec2 uv;

uniform int shape;

void circle() {
    if (length(uv-0.5) < 0.5)
        Material1(fragColor);
    else
        Material2(fragColor);
}

void main() {
    if (shape == 0) {
        circle();
    }
}
