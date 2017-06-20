#vertex Proj

require Position in World as vec3 position;
require Normal in World as vec3 normal;
require Light;

uniform vec3 ambient;
uniform vec3 diffuse;

void main() {
    fragColor = vec4(ambient, 1);
    for (int i = 0; i < pointLightNum; i++) {
        float d = max(0., dot(normalize(pointLights[i].pos - position), normal));
        fragColor.rgb += pointLights[i].diffuse * diffuse * d;
    }
}
