#vertex Proj

require UV as vec2 vUV;

uniform sampler2D tex;

void main() {
  fragColor = texture(tex, vUV);
}
