#version 400

in vec3 vNormal;
in vec2 vUV;
out vec4 fragColor;

void main() {
  fragColor = vec4(abs(vec3(vNormal)), 1);
}
