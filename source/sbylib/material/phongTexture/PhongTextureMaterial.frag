#vertex Proj

require Position in World as vec3 position;
require Position in View as vec3 vPosition;
require Normal in World as vec3 normal;
require UV as vec2 uv;
require Light;

uniform vec4 ambient;
uniform vec3 diffuse;
uniform vec3 specular;
uniform float power;
uniform sampler2D tex;

void main() {
    fragColor = ambient;
    vec3 n = normalize(normal);
    for (int i = 0; i < pointLightNum; i++) {
        float d = max(0.0, dot(normalize(pointLights[i].pos - position), n));
        fragColor.rgb += pointLights[i].diffuse * diffuse * d;

        float s = max(0.0, dot(normalize(reflect(position - pointLights[i].pos, n)), -normalize(vPosition)));
        fragColor.rgb += specular * pow(s, power);
        // fragColor.rgb += pointLights[i].specular * specular * pow(s, power);
    }

    // texture
    fragColor = texture(tex, vec2(uv.x, 1 - uv.y));
}
