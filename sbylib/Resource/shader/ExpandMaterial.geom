#vertex Local

layout(triangles) in;
layout(triangle_strip, max_vertices=64) out;

uniform float expandScale;
uniform bool expand;

void main() {

    for (int i = 0; i < gl_in.length(); i++) {
        vec3 pos = gl_in[i].gl_Position.xyz;
        if (expand) {
            pos *= expandScale;
        }
        emitLocalVertex(i, vec4(pos, 1));
    }
    EndPrimitive();
}
