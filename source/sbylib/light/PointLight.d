module sbylib.light.PointLight;

import sbylib.math.Vector;

struct PointLight {
    vec3 pos;
    vec3 diffuse;

    enum declareCode = 
            "struct Point Light {
                vec3 pos;
                vec3 diffuse;
            }";
}

struct PointLightBlock {
    int num;
    PointLight[10] lights;
}
