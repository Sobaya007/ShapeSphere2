#vertex Proj

require Position in World as vec3 position;
require UV as vec2 uv;

uniform vec4 darkColor;
uniform vec4 lightColor;
uniform vec4 borderColor;
uniform float value; // ∈ [0, 1]
uniform vec2 size;
uniform float borderSize;

void main() {

    fragColor = vec4(0);

    vec2 p = abs((uv - 0.5)*size);

    {
        // 枠
        vec2 q = max(vec2(0), p - (size/2 - vec2(borderSize))) / borderSize;

        float power = 5.0;
        float d = pow(pow(q.x, power) + pow(q.y, power), 1.0/power);

        float t = smoothstep(0.1, 0.2, abs(d - 0.5));
        fragColor += mix(borderColor, vec4(0), t);

        if (d>0.5) return;
    }

    {
        // 内側
        vec2 q = max(vec2(0), p - (size/2 - vec2(borderSize*2))) / borderSize;

        float power = 5.0;
        float d = pow(pow(q.x, power) + pow(q.y, power), 1.0/power);

        float t = smoothstep(0.0, 0.9, d);
        vec4 col1 = mix(lightColor, darkColor, value*0.8);
        fragColor += mix(col1, darkColor, t);
    }

    // {
    //     // 内側
    //     vec2 p = (uv-0.5)*2.0*size;
    //     vec2 q = smoothstep(size-borderSize*4.0, size-borderSize, abs(p));
    //
    //     vec4 col1 = mix(lightColor, darkColor, value);
    //     fragColor += mix(col1, darkColor, max(q.x, q.y));
    // }
}

// void main() {
//     float borderSize = 10.0;
//
//     fragColor = vec4(0);
//
//     {
//         // 枠
//         vec2 p = min(uv*size, size - uv*size);
//
//         float d;
//         if (p.x<borderSize && p.y<borderSize) {
//             vec2 q = (vec2(borderSize) - p)/borderSize;
//             d = length(q);
//         } else {
//             d = max(borderSize - p.x, borderSize - p.y)/borderSize;
//         }
//
//         float t = smoothstep(0.0, 0.1, abs(d-0.5));
//         float a = mix(borderColor.w, 0.0, t);
//         fragColor += vec4(borderColor.xyz, a);
//
//         if (d>0.5) return;
//     }
//
//     {
//         // 内側
//         vec2 p = (uv-0.5)*2.0*size;
//         vec2 q = smoothstep(size-borderSize*4.0, size-borderSize, abs(p));
//
//         vec4 col1 = mix(lightColor, darkColor, value);
//         fragColor += mix(col1, darkColor, max(q.x, q.y));
//     }
// }
