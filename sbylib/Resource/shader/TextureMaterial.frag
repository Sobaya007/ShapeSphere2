#vertex Proj

require UV as vec2 uv;
uniform sampler2D tex;
uniform float alpha;

void main() {
    fragColor = texture(tex, uv);
    if (fragColor.a == 0) discard;
    fragColor.a *= alpha;
}
