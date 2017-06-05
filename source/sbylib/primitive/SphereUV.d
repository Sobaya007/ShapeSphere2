module sbylib.primitive.SphereUV;

import derelict.opengl;

import std.math;

import sbylib.primitive;
import sbylib.utils;
import sbylib.math;
import sbylib.gl;
import sbylib.shadertemplates;
import sbylib.core;

class SphereUV : Primitive {

    this(ShaderProgram shader = null)  {
        if (shader is null) shader = ShaderStore.getShader("NormalGenerate");
        super(getVertices(20,20), getIndices(20,20), shader);
        getCustom.addDynamicUniformMatrix!(4, "mWorld")({return getWorldMatrix.array;});
        getCustom.addDynamicUniformMatrix!(4, "mViewProj")({return SbyWorld.currentCamera.getViewProjectionMatrix.array;});
    }

    override bool step() {
        getCustom.draw();
        return true;
    }

    static vec3[] getVertices(uint tCut, uint pCut) {
        vec3[] result;
        //southern
        result ~= vec3(0,-1,0);
        foreach_reverse (i; 0..pCut) {
            auto phi = i * PI / (2 * pCut);
            foreach (j; 0..tCut) {
                auto theta = j * 2 * PI / tCut;
                result ~= vec3(
                         -cos(phi) * cos(theta),
                         -sin(phi),
                         -cos(phi) * sin(theta)
                );
            }
        }

        //northern
        result ~= vec3(0,1,0);
        foreach_reverse (i; 0..pCut) {
            auto phi = i * PI / (2 * pCut);
            foreach (j; 0..tCut) {
                auto theta = j * 2 * PI / tCut;
                result ~= vec3(
                        cos(phi) * cos(theta),
                        sin(phi),
                        cos(phi) * sin(theta)
                );
            }
        }
        return result;
    }

    static uint[][] getIndices(uint tCut, uint pCut) {
        uint[][] result;

        //southernてっぺん
        foreach (i; 0..tCut) {
            result ~= [0, i+1, (i+1) % tCut + 1];
        }

        //southernまわり
        foreach (i; 0..pCut-1) {
            foreach (j; 0..tCut) {
                result ~= [
                1 + j + i * tCut, 
                1 + j+ (i+1) * tCut,
                    1 + (j+1) % tCut + (i+1) * tCut,
                    1 + (j+1) % tCut + i * tCut,
                    ];
            }
        }

        //northernてっぺん
        foreach (i; 0..tCut) {
            result ~= [pCut*tCut + 1,pCut*tCut + 1 + (i+1) % tCut + 1, pCut*tCut + 1 + i + 1];
        }

        //northernまわり
        foreach (i; 0..pCut-1) {
            foreach (j; 0..tCut) {
                result ~= [
                pCut*tCut+2 + j + i * tCut,
                pCut*tCut+2 + (j+1) % tCut + i * tCut, 
                    pCut*tCut+2 + (j+1) % tCut + (i+1) * tCut,
                    pCut*tCut+2 + j+ (i+1) * tCut, 
                    ];
            }
        }

        //側面
        foreach (i; 0..tCut) {
            result ~= [
            (pCut-1) * tCut + 1 + i,
            (2*pCut-2) * tCut + 2 + i + tCut / 2,
                (2*pCut-2) * tCut + 2 + (i+1) % tCut + tCut / 2,
                (pCut-1) * tCut + 1 + (i+1) % tCut,
                ];
        }
        return result;
    }
}
