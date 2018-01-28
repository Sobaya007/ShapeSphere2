#vertex Proj

require Position in World as vec3 position;
require Position in View as vec3 vPosition;
require Normal in World as vec3 normal;
require Normal in View as vec3 vNormal;

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
}
