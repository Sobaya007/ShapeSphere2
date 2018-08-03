#vertex Proj

require Normal in World as vec3 normal;
require UV as vec2 uv;

out vec4 fragColor0;
out vec4 fragColor1;

void main() {
    fragColor0 = vec4(normal*0.5+0.5, 1);
    fragColor1 = vec4(uv, 1, 1);
}
