module sbylib.light.PointLight;

import sbylib.math.Vector;

struct PointLight {
    vec3 pos;
    vec3 diffuse;
}

struct PointLightBlock {
    int num;
    float[4] po;
}

enum PointLightDeclareCode = 
        "struct PointLight {
                vec3 pos;
                vec3 diffuse;
            };";
