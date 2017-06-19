#vertex Proj

require Position in World as vec3 vPosition;
require Normal in World as vec3 vNormal;
require Light;

uniform vec3 ambient = vec3(0.1);
uniform vec3 diffuse = vec3(1);

void main() {
    fragColor = vec4(ambient, 1);
    for (int i = 0; i < pointLightNum; i++) {
        float d = max(0., dot(normalize(pointLights[i].pos - vPosition), vNormal));
        fragColor.rgb += pointLights[i].diffuse;
        fragColor.rgb = vec3(1);
    }
}
