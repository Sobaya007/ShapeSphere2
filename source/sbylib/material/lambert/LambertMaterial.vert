
attribute vec3 vertex;
attribute vec3 normal;

uniform mat4 worldMatrix;
uniform mat4 viewMatrix;
uniform mat4 projMatrix;

out vec3 vNormal;

void main() {
  gl_Position = projMatrix * viewMatrix * worldMatrix * vec4(vertex, 1);
  vNormal = worldMatrix * vec4(normal, 0);
}
