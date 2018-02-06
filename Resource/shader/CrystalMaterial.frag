#vertex Proj

uniform sampler2D backBuffer;

require Position in View as vec3 vPos;
require Normal in View as vec3 vNormal;
require Position in Proj as vec3 projPos;

require Light;

void main() {
    vec2 uv = projPos.xy / projPos.z * .5 + .5;

    vec3 dir = normalize(vPos);
    dir = refract(dir, normalize(vNormal), 0.1) * 0.1;
    fragColor = texture(backBuffer, uv + dir.xy);
    //fragColor.rgb += vec3(0,0.1, 0.2) * 0.8;

    vec3 l = -normalize(vec3(1,1,1));
    float d = max(0.0, dot(-l, vNormal));
    float s = pow(max(0.0, dot(-normalize(vPos), reflect(l,vNormal))), 2);
    fragColor.rgb += vec3(d + s) * 0.1;
}
