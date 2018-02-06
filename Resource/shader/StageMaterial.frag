#vertex Proj

require Position in World as vec3 position;
require Position in View as vec3 vPosition;
require Position in Proj as vec3 pPosition;
require Normal in World as vec3 normal;
require Normal in View as vec3 vNormal;

require Light;

uniform vec4 ambient;
uniform vec3 diffuse;
uniform vec3 specular;
uniform float power;

void main() {
    fragColor = ambient;
    vec3 n = normalize(vNormal);
    float d = max(0.0, dot(normalize(vPosition), -n));
    fragColor.rgb += vec3(2) * diffuse * d;
    fragColor.rgb *= clamp((100 - length(vPosition)) * 0.01, 0, 1);

    for (int i = 0; i < pointLightNum; i++) {
        vec3 l = pointLights[i].pos - position;
        float d = max(0.0, dot(normalize(l), normalize(normal)));
        d *= exp(-length(l) * length(l)) * 20;
        fragColor.rgb += pointLights[i].diffuse * d;
    }
}
