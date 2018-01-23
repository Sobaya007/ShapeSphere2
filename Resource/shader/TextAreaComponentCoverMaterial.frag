#vertex Proj

require Position in World as vec3 position;
require UV as vec2 uv;

uniform float opacity;
uniform vec4 color;

void main() {
    fragColor = color;
    fragColor.a *= opacity;
}
