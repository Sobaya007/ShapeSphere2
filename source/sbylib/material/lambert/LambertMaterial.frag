#vertex Proj

require Normal in World as vec3 vNormal;
require UV as vec2 vUV;

uniform Po {
  vec3 color;
};

void main() {
  fragColor = vec4(vUV * .5 + .5, 1, 1);
}
