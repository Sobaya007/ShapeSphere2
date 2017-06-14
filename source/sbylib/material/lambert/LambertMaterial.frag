in vec3 vNormal;
in vec2 vUV;
out vec4 fragColor;

float one = 1.0f;

uniform Po {
  vec3 color;
};

vec2 add(vec2 a, vec2 b) {
  return a + b;
}

void main() {
  fragColor = vec4(abs(vec3(vNormal)), 1);
  fragColor.rgb = color;
}
