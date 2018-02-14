#vertex Proj

require Position in World as vec3 position;
require UV as vec2 uv;

uniform vec4 borderColor;
uniform vec4 backgroundColor;
uniform vec2 size;
uniform float borderSize;

void main() {
    fragColor = vec4(0);

    vec2 p = (uv - 0.5)*size;
    p = abs(p);

    vec2 q = max(vec2(0), p - (size/2.0 - vec2(borderSize))) / borderSize;

    float power = 5.0;
    float d = pow(pow(q.x, power) + pow(q.y, power), 1.0/power);
    if (d<0.5) {
        fragColor = backgroundColor;
    }

    float t = smoothstep(0.1, 0.5, abs(d - 0.5)*2.0);
    fragColor += mix(borderColor, vec4(0), t);
}
