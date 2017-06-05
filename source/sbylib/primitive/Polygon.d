module sbylib.primitive.Polygon;

import sbylib.primitive;
import sbylib.math;
import sbylib.shadertemplates;
import std.conv, std.range;

class Polygon : Primitive {

    private {
        vec3[] mVertices;
        vec3 mNormal;
    }

    this(vec3[] vertices) { 
        this.mVertices = vertices;
        auto vList = new VertexList(vertices);
        auto face = new Face(to!uint(vertices.length).iota.array, Face.Type.TriangleFan);
        auto fList = new FaceList([face]);
        fList.setVertexList(vList);
        this.mNormal = face.computeNormal;
        super(fList, ShaderStore.getShader("NormalGenerate"));
    }

    @property {
        @nogc {
            vec3[] Vertices() {
                return mVertices;
            }

            vec3 Normal() {
                return mNormal;
            }
        }

        override {
            vec3 Position() {
                return super.Position();
            }

            quat Orientation() {
                return super.Orientation();
            }

            vec3 Position(vec3 p) {
                auto result = super.Position(p);
                auto mat = getWorldMatrix();
                foreach (ref v; mVertices) {
                    v = (mat * vec4(v,1)).xyz;
                }
                return result;
            }

            quat Orientation(quat q) {
                auto result = super.Orientation(q);
                auto mat = getWorldMatrix();
                foreach (ref v; mVertices) {
                    v = (mat * vec4(v,1)).xyz;
                }
                mNormal = (mat * vec4(mNormal,0)).xyz;
                return result;
            }
        }

    }
}
