#vertex Proj

require UV as vec2 uv;

float aoFactor() {
    float dx = min(uv.x, 1 - uv.x);
    float dy = min(uv.y, 1 - uv.y);

    float factor = min(dx, dy);
    return min(1,factor * 0.1 + 0.95);
}

float makeGloove() {
    const float N = 10;
    vec2 uv2 = mod(uv, vec2(1 / N)) * N;

    if (abs(uv2.x - 0.5) < 0.01) return 0.1;
    if (abs(uv2.y - 0.5) < 0.01) return 0.1;
    return 1;
}

void main() {
    fragColor = vec4(1);

    fragColor.rgb *= aoFactor();
    fragColor.rgb *= makeGloove();
}
