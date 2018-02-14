module sbylib.light.PointLight;

import sbylib.math.Vector; 
struct PointLight {
align (16):
    vec3 pos;
    vec3 diffuse;
}

struct PointLightBlock {
align (16):
    int num;
    PointLight[100] lights;
}

enum PointLightDeclareCode = 
        "struct PointLight {
        vec3 pos;
        vec3 diffuse;
        };";

enum PointLightBlockDeclareCode = 
        "uniform PointLightBlock {
        int pointLightNum;
        PointLight pointLights[10];
        };";
