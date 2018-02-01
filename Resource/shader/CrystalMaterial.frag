#vertex Proj

uniform sampler2D backBuffer;

require Position in Proj as vec3 projPos;

void main() {
    vec2 uv = projPos.xy / projPos.z * .5 + .5;
    fragColor = texture(backBuffer, uv);
    fragColor.rgb = vec3(1) - fragColor.rgb;
    fragColor = vec4(uv, 1, 1);
}
