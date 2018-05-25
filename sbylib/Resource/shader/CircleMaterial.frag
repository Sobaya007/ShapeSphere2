#vertex Proj

require UV as vec2 uv;

uniform vec3 color;

void main() {
    vec2 p = uv - vec2(.5);
    if (length(p) > .5) discard;
    fragColor = vec4(color, 1);
}
