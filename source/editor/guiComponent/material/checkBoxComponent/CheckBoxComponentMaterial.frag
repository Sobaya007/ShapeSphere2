#vertex Proj

require Position in World as vec3 position;
require UV as vec2 uv;

uniform vec4 backColor;
uniform vec4 foreColor;
uniform bool isChecked;

float crs(vec2 v1, vec2 v2) {
    return v1.x*v2.y - v1.y*v2.x;
}

// 2点v1, v2を端点に持つ線分との距離を返す
float line(vec2 p, vec2 v1, vec2 v2) {
    p  -= v1;
    vec2 v = v2-v1;
    float t = dot(p, normalize(v));
    if (t<0.0) {
        return length(p);
    } else if (t>length(v)) {
        return length(p-v);
    } else {
        return abs(crs(p, normalize(v)));
    }
}

void main() {

    vec2 p = (uv - vec2(0.5))*2.0; // [-1, 1]✕[-1, 1]
    float t = 1e10;
    float opacity = 1.0;

    {
        // 枠
        float power = 10.0;
        float d = pow(pow(p.x, power) + pow(p.y, power), 1.0/power);
        t = min(t, smoothstep(0.0, 0.1, abs(d - 0.9)));
        opacity = smoothstep(0.0, 0.1, 0.9 - d);
    }

    if (isChecked) {
        // チェックマーク
        float d1 = line(p, vec2(-0.5, 0.0), vec2(-0.15, -0.4));
        float d2 = line(p, vec2(0.5, 0.5), vec2(-0.15, -0.4));
        float d = min(d1, d2);
        t = min(t, smoothstep(0.08, 0.18, d));
    }

    fragColor = mix(foreColor, backColor, t);
    fragColor.a *= opacity;
}
