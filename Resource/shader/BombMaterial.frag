#vertex Proj

in vec3 vNormal;
in flat int flag;

require Position in World as vec3 position;
require Position in View as vec3 vPosition;
require Light;
require worldMatrix;
require viewMatrix;

uniform sampler2D noise;
uniform float time;
uniform float lightScale;

vec3 noiseF(vec2 seed) {
    seed /= 50.5141919;
    return texture(noise, seed).rgb;
}

float rand(vec2 seed) {
    vec3 n = noiseF(seed);
    return dot(n, normalize(vec3(1,2,3)));
}

float rand(vec3 seed) {
    return dot(vec3(rand(seed.xy), rand(seed.yz), rand(seed.zx)), normalize(vec3(23,67,43)));
}

void main() {
    if (flag == 1) {
        fragColor = vec4(1,0,0,1) + vec4(0,1,0,0) * rand(position + vec3(sin(time*0.02+rand(position.yz)), cos(time * 0.0234+rand(position.zx)), sin(time*0.0345+0.2+rand(position.xy)))) * 0.4;
        fragColor.rgb *= lightScale;
    } else {
        fragColor = vec4(0);
        for (int i = 0; i < pointLightNum; i++) {
            const float power = 20.0;
            vec3 vLightPos = (viewMatrix * worldMatrix * vec4(pointLights[i].pos, 1)).xyz;
            float s = max(0.0, dot(normalize(reflect(vPosition - vLightPos, vNormal)), -normalize(vPosition)));
            fragColor.rgb += vec3(0.1) * pow(s, power);
        }
        fragColor.rgb += vec3(1, 0.7, 0.1) * lightScale * 0.1;
        fragColor.a = 1;
    }
}
