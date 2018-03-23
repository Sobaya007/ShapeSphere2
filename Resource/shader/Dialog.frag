#vertex Proj

require UV as vec2 uv;

uniform float progress;
uniform vec2 size;
uniform vec4 color;

bool po() {
    float BORDER_Y = 0.1;
    float BORDER_X = BORDER_Y * size.y / size.x;
    if (0 < progress) {
        if (uv.y < BORDER_Y && uv.x < progress * 4) return true;
    }
    if (0.25 < progress) {
        if (1-uv.x < BORDER_X && uv.y < (progress-0.25) * 4) return true;
    }
    if (0.5 < progress) {
        if (1-uv.y < BORDER_Y && 1-uv.x < (progress-0.5) * 4) return true;
    }
    if (0.75 < progress) {
        if (uv.x < BORDER_X && 1-uv.y < (progress-0.75) * 4) return true;
    }
    return false;
}

void main() {
    if (po()) gl_FragColor = color;
    else discard;
}
