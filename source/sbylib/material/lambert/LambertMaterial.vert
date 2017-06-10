
attribute vec4 vertex;
attribute vec3 normal;

uniform mat4 worldMatrix;
uniform mat4 viewMatrix;
uniform mat4 projMatrix;

void main() {
  gl_Position = worldMatrix
}
