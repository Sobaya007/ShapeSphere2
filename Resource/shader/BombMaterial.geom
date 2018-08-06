#vertex Local

layout(triangles) in;
layout(triangle_strip, max_vertices=64) out;

out vec3 vNormal;
out flat int flag;

void emitA(vec4 p, vec3 n, int i) {
    p.xyz *= 0.9;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    flag = 1;
    emitLocalVertex(i, p);
}

void emitB(vec4 p, vec3 n, int i) {
    float pn = dot(p.xyz, n);
    p.xyz -= pn * n;
    p.xyz *= 0.8;
    p.xyz += pn * n;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    flag = 0;
    emitLocalVertex(i, p);
}

void emitB2(vec4 p, vec3 n, int i) {
    float pn = dot(p.xyz, n);
    p.xyz -= pn * n;
    p.xyz *= 0.8;
    p.xyz += pn * n;
    p.xyz -= 0.1 * n;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    flag = 0;
    emitLocalVertex(i, p);
}

void main() {

    vec3 a = gl_in[0].gl_Position.xyz;
    vec3 b = gl_in[1].gl_Position.xyz;
    vec3 c = gl_in[2].gl_Position.xyz;

    vec3 n = -normalize(cross(c-b, b-a));

    vec3 g = vec3(0);
    for (int i = 0; i < gl_in.length(); i++) {
        g += gl_in[i].gl_Position.xyz;
    }
    g /= 3;

    for (int i = 0; i < gl_in.length(); i++) {
        vec4 p = gl_in[i].gl_Position;
        emitA(p, n, i);
    }
    EndPrimitive();

    for (int i = 0; i < gl_in.length(); i++) {
        vec4 p = gl_in[i].gl_Position;
        emitB(p, n, i);
    }
    EndPrimitive();
    for (int i = 0; i < gl_in.length(); i++) {
        vec4 p0 = gl_in[i].gl_Position;
        vec4 p1 = gl_in[(i+1)%gl_in.length()].gl_Position;
        emitB(p0, n, 0);
        emitB(p1, n, 1);
        emitB2(p0, n, 2);
        EndPrimitive();
        emitB2(p0, n, 0);
        emitB(p1, n, 1);
        emitB(p0, n, 2);
        EndPrimitive();

        emitB(p1, n, 0);
        emitB2(p0, n, 1);
        emitB2(p1, n, 2);
        EndPrimitive();
        emitB2(p1, n, 0);
        emitB2(p0, n, 1);
        emitB(p1, n, 2);
        EndPrimitive();
    }
}
