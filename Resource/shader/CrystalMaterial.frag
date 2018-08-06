#vertex Proj

uniform sampler2D backBuffer;

require Position in World as vec3 position;
require Normal in World as vec3 normal;
require Position in View as vec3 vPos;
require Normal in View as vec3 vNormal;
require Position in Proj as vec3 projPos;

require Light;

uniform vec3 cameraPos;

void main() {
    vec2 uv = projPos.xy / projPos.z * .5 + .5;

    vec3 dir = normalize(vPos);
    dir = refract(dir, normalize(vNormal), 0.1) * 0.1;
    fragColor = texture(backBuffer, uv + dir.xy);

    for (int i = 0; i < pointLightNum; i++) {
        vec3 l = pointLights[i].pos - position;
        float d = exp(-length(l)) * 10;
        fragColor.rgb += pointLights[i].diffuse * d;
        fragColor.rgb += vec3(1) * dot(dir, normalize(l));
    }
}
