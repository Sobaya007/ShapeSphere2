#vertex Proj

require UV as vec2 vUV;

uniform sampler2D tex;
uniform sampler2D tex2;

void main() {
  vec4 color = texture(tex, vUV);
  vec4 color2 = texture(tex2, vUV);
  if (color.a == 0. && color2.a == 0.) discard;
  fragColor = color2;
}
