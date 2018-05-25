#vertex Proj

require Position in World as vec3 position;
require UV as vec2 uv;

uniform vec4 borderColor;
uniform vec2 size;
uniform float borderSize;
uniform float contentScale;

void main() {
    vec2 p = (uv - 0.5)*size;
    p.x = abs(p.x);
    p.y = max(p.y, -p.y + (1.0 - contentScale)*(size.y - 2*borderSize));

    vec2 q = max(vec2(0), p - (size/2.0 - vec2(borderSize))) / borderSize;

    float power = 5.0;
    float d = pow(pow(q.x, power) + pow(q.y, power), 1.0/power);

    float t = smoothstep(0.1, 0.5, abs(d - 0.5)*2.0);
    fragColor = mix(borderColor, vec4(0), t);

}
