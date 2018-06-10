#vertex Local

layout(triangles) in;
layout(triangle_strip, max_vertices=64) out;

out vec3 position;
out vec3 vPosition;
out vec3 vNormal;
out flat int flag;

require worldMatrix;
require viewMatrix;
require projMatrix;

void emitA(vec4 p, vec3 n) {
    p.xyz *= 0.9;
    position = (worldMatrix * p).xyz;
    vPosition = (viewMatrix * worldMatrix * p).xyz;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    gl_Position = projMatrix * viewMatrix * worldMatrix * p;
    flag = 1;
    EmitVertex();
}

void emitB(vec4 p, vec3 n) {
    float pn = dot(p.xyz, n);
    p.xyz -= pn * n;
    p.xyz *= 0.8;
    p.xyz += pn * n;
    position = (worldMatrix * p).xyz;
    vPosition = (viewMatrix * worldMatrix * p).xyz;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    gl_Position = projMatrix * viewMatrix * worldMatrix * p;
    flag = 0;
    EmitVertex();
}

void emitB2(vec4 p, vec3 n) {
    float pn = dot(p.xyz, n);
    p.xyz -= pn * n;
    p.xyz *= 0.8;
    p.xyz += pn * n;
    p.xyz -= 0.1 * n;
    position = (worldMatrix * p).xyz;
    vPosition = (viewMatrix * worldMatrix * p).xyz;
    vNormal = normalize((viewMatrix * worldMatrix * vec4(n, 0)).xyz);
    gl_Position = projMatrix * viewMatrix * worldMatrix * p;
    flag = 0;
    EmitVertex();
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
        emitA(p, n);
    }
    EndPrimitive();

    for (int i = 0; i < gl_in.length(); i++) {
        vec4 p = gl_in[i].gl_Position;
        emitB(p, n);
    }
    EndPrimitive();
    for (int i = 0; i < gl_in.length(); i++) {
        vec4 p0 = gl_in[i].gl_Position;
        vec4 p1 = gl_in[(i+1)%gl_in.length()].gl_Position;
        emitB(p0, n);
        emitB(p1, n);
        emitB2(p0, n);
        EndPrimitive();
        emitB2(p0, n);
        emitB(p1, n);
        emitB(p0, n);
        EndPrimitive();

        emitB(p1, n);
        emitB2(p0, n);
        emitB2(p1, n);
        EndPrimitive();
        emitB2(p1, n);
        emitB2(p0, n);
        emitB(p1, n);
        EndPrimitive();
    }
}
