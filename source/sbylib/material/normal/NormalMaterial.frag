#vertex Proj

require Normal in World as vec3 normal;

void main() {
    fragColor = vec4(normal * .5 + .5, 1);
}
