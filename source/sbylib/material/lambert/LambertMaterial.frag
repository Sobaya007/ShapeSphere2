#vertex Proj

require Normal in World as flat vec3 vNormal;

void main() {
  fragColor = vec4(vNormal * .5 + .5, 1);
}
