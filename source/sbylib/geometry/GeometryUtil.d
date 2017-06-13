module sbylib.geometry.GeometryUtil;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Attribute;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.geometry.Face;
import sbylib.math.Vector;
import std.algorithm;
import std.array;

class GeometryUtil(Attribute[] Attributes, Prim Mode) {
    alias GeometryA = GeometryTemp!(Attributes, Mode);
    alias VertexA = Vertex!(Attributes);
static:

    GeometryTemp!(Attributes, Prim.Triangle) expandVertex(GeometryA geom) {
        auto newVertices = geom.faces.map!(face => face.indexList).reduce!((a,b) => a ~ b).map!(index => geom.vertices[index]).array;
        int newIndex = 0;
        Face[] newFaceList;
        foreach (face; geom.faces) {
            uint[] newIndexList;
            foreach (index; 0..face.indexList.length) {
                newIndexList ~= newIndex++;
            }
            newFaceList ~= new Face(newIndexList);
        }
        return new GeometryTemp!(Attributes, Prim.Triangle)(newVertices, newFaceList);
    }

    vec3 computeNormal(const vec3[] vertices) {
        alias v = vertices;
        auto n = cross(v[2] - v[1], v[0] - v[1]).normalize;
        if (n.hasNaN) {
            throw new Exception("detected NaN");
        }
        return n;
    }

    alias GeometryN = GeometryTemp!(Attributes ~ Attribute(3, "normal"), Mode);
    alias VertexN = Vertex!(Attributes ~ Attribute(3, "normal"));

    GeometryN flatNormal(GeometryA geom) {
        assert(geom.faces.map!(face => face.indexList.length).sum == geom.vertices.length, "Before flatten normals, please expand vertices.");
        VertexN[] newVertices;
        foreach (face; geom.faces) {
            auto vertices = face.indexList.map!(i => geom.vertices[i]).array;
            auto normal = computeNormal(vertices.map!(v => v.position).array);
            foreach (v; vertices) {
                auto newV = v.to!(Attributes ~ Attribute(3, "normal"));
                newV.normal = normal;
                newVertices ~= newV;
            }
        }
        return new GeometryN(newVertices, geom.faces);
    }


//    void generateSmoothNormal() {
//        foreach (v; mVertexList) {
//            v.Normal = vec3(0);
//        }
//        foreach (v; mVertexList) {
//            foreach (face; v.mParents) {
//                v.Normal = v.Normal + face.computeNormal();
//            }
//        }
//        foreach (v; mVertexList) {
//            v.Normal = normalize(v.Normal);
//        }
//    }
//
//    void generateTexcoord() {
//        assert(getIndexList.length == mVertexList.length);
//        foreach (face; mFaceList) {
//            auto children = face.getChildren;
//            assert(children.length >= 2);
//            auto center = face.computeCenter();
//            auto z = face.computeNormal();
//            auto x = normalize(children[0].Position - center);
//            auto y = cross(z, x).normalize;
//            float minS = float.infinity;
//            float minT = float.infinity;
//            float maxS = -float.infinity;
//            float maxT = -float.infinity;
//            foreach (v; children) {
//                float s = dot(v.Position, x);
//                float t = dot(v.Position, y);
//                v.Texcoord = vec2(s,t);
//                minS = min(minS, s);
//                minT = min(minT, t);
//                maxS = max(maxS, s);
//                maxT = max(maxT, t);
//            }
//            vec2 origin = vec2(minS, minT);
//            vec2 scale = 1 / vec2(maxS - minS, maxT - minT);
//            alias conv = tc => (tc - origin) * scale;
//            foreach (v; children) {
//                v.Texcoord = conv(v.Texcoord);
//            }
//        }
//    }
}
