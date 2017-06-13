#version 400

in vec3 pos;
in vec3 normal;

uniform mat4 worldMatrix;
uniform mat4 viewMatrix;
uniform mat4 projMatrix;

out vec3 vNormal;

void main() {
  gl_Position = viewMatrix * worldMatrix * vec4(pos, 1);
  vNormal = (worldMatrix * vec4(normal, 0)).xyz;
}
