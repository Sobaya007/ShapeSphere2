#vertex Proj

require UV as vec2 tc;
uniform vec2 xvec;
uniform vec2 yvec;
uniform vec2 zvec;

float dist(vec2 v, vec2 p) {
    float len = length(p);
    float dot = dot(v, p);
    return sqrt(len*len - dot*dot);
}

void main() {
    vec2 uv = tc - 0.5;
    const float border = 0.02;
    fragColor = vec4(0,0,0,0.4);
    if (length(uv) > 0.4) return;
    fragColor +=
        max(sign(border - dist(xvec, uv)), 0) * vec4(0.5 + 0.5 * max(sign(dot(xvec, uv)), 0), 0, 0, 1)
      + max(sign(border - dist(yvec, uv)), 0) * vec4(0, 0.5 + 0.5 * max(sign(dot(yvec, uv)), 0), 0, 1)
      + max(sign(border - dist(zvec, uv)), 0) * vec4(0, 0, 0.5 + 0.5 * max(sign(dot(zvec, uv)), 0), 1);
}
