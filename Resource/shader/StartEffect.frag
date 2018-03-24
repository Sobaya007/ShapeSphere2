#vertex Proj

require UV as vec2 uv;

uniform sampler2D texture;
uniform float textAlpha;
uniform float fragWidth;
uniform float fragHeight;
uniform float lineRate;

void main() {
    vec2 po = gl_PointCoord;
    po.y = 1 - po.y;
    vec2 uv2 = uv + po * vec2(fragWidth, fragHeight);
    uv2.y = 1 - uv2.y;
    gl_FragColor = vec4(texture2D(texture, uv2).r);
    if (abs(uv2.y - 0.9) < 0.01 && abs(uv2.x - 0.5) * 2 < lineRate) gl_FragColor = vec4(1);
    gl_FragColor.a *= textAlpha;
    gl_FragColor.rgb *= vec3(1,1,0.7);
}
