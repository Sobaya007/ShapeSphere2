#vertex Proj

require Position in World as vec3 position;
require Position in View as vec3 vPosition;
require Normal in World as vec3 normal;
require UV as vec2 uv;
require viewMatrix;
require Light;

uniform vec4 ambient;
uniform vec3 diffuse;
uniform vec3 specular;
uniform float power;

void main() {
    fragColor = ambient;

    vec3 cameraDir = (inverse(viewMatrix) * vec4(-normalize(vPosition), 0)).xyz;
    vec3 n;
    if (gl_FrontFacing) {
        n = normal;
    } else {
        n = -normal;
    }
    for (int i = 0; i < pointLightNum; i++) {
        float d = max(0.0, dot(normalize(pointLights[i].pos - position), normalize(n)));
        fragColor.rgb += pointLights[i].diffuse * diffuse * d;

        float s = max(0.0, dot(normalize(reflect(position - pointLights[i].pos, n)), cameraDir));
        fragColor.rgb += specular * pow(s, power);
    }
}
