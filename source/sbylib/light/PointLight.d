module sbylib.light.PointLight;

import sbylib.math.Vector;

struct PointLight {
    vec3 pos;
    vec3 diffuse;
}

struct float4 {
    float x;
    float y;
    float z;
    float w;
}

struct PointLightBlock {
    int num;
    float a;
}

enum PointLightDeclareCode = 
        "struct PointLight {
                vec3 pos;
                vec3 diffuse;
            };";
