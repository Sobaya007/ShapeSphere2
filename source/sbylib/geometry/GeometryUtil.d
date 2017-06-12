module sbylib.geometry.GeometryUtil;

import sbylib.wrapper.gl.Constants;

class GeometryUtil(string[] Attributes, Prim Mode) {
    alias GeometryA = Geometry!(Attributes, Mode);
static:

    Geometry!(Attributes, Prim.Triangle) expandVertex(GeometryA geom) {
        auto newVertices = geom.faces.map!(face => face.indexList).join.map!(index => geom.vertices[index]).array;
        int newIndex = 0;
        Face[] newFaceList;
        foreach (face; geom.faces) {
            uint[] newIndexList;
            foreach (index; 0..face.indexList.length) {
                newIndexList ~= newIndex++;
            }
            newFaceList ~= new Face(newIndexList);
        }
        return new Geometry!(Attributes, Prim.Triangle)(newVertices, newFaceList);
    }

    vec3 computeNormal(vec3[3] vertices) {
        alias v = vertices;
        auto n = cross(v[2] - v[1], v[0] - v[1]).normalize;
        if (n.hasNaN) {
            throw new Exception("detected NaN");
        }
        return n;
    }

    static if (Attributes.any!(attr => attr == "normal")) {
        alias GeometryN = GeometryA;
        alias VertexN = Vertex!(Attributes);
    } else {
        alias GeometryN = Gemetry!(Attributes ~ "vec3" ~  "normal", Mode);
        alias VertexN = Vertex!(Attributes ~ "vec3" ~ "normal");
    }

    GeometryN flatNormal(GeometryA geom) {
        assert(geom.faces.map!(face => face.indexList.length).sum == geom.vertices.length, "Before flatten normals, please expand vertices.");
        VertexN[] newVertices;
        foreach (face; geom.faces) {
            vec3[3] vertices = [
            geom.vertices[face.indexList[0]].position,
                geom.vertices[face.indexList[1]].position,
            geom.vertices[face.indexList[2]].position
            ];
            auto normal = computeNormal(vertices);
            foreach (v; vertices) {
                auto newV = v.to!(Attributes ~ "vec3" ~ "normal");
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
