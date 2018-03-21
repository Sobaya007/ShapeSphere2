#version 400

in vec3 _position;
in vec2 _uv;

out vec2 uv;

uniform float size;

void main() {
    gl_Position = vec4(_position, 1);
    
    uv = _uv;

    gl_PointSize = size;
}
