#vertex Proj

require UV as vec2 uv;

uniform sampler2D texture;
uniform float textAlpha;

void main() {
    vec2 po = gl_PointCoord;
    if (distance(po, vec2(0.5)) >= 0.5) discard;
    gl_FragColor = vec4(texture2D(texture, vec2(uv.x,1-uv.y)).r);
    gl_FragColor.a *= textAlpha;
}
