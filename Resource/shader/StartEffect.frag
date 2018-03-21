#vertex Proj

require UV as vec2 uv;

uniform sampler2D texture;

void main() {
    vec2 po = gl_PointCoord;
    if (distance(po, vec2(0.5)) >= 0.5) discard;
    gl_FragColor = texture2D(texture, uv);
}
