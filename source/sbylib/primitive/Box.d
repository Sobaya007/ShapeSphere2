module sbylib.primitive.Box;

import sbylib;

class Box : Primitive {
    private static{
        vec3[] vertices;
        uint[][] indices;
        FaceList faces;
    }

    this()  {
        super(faces, ShaderStore.getShader("TexcoordShow"));
    }

    static vec3[] getVertices() {
        return vertices.dup;
    }

    static uint[][] getIndices() {
        return indices.dup;
    }

    static this() {
        faces = new FaceList(indices = [
                [2,3,1,0], //奥
                [4,5,7,6], //手前
                [6,7,3,2], //上
                [0,1,5,4], //下
                [1,3,7,5], //左
                [4,6,2,0]  //右
                ], Face.Type.TriangleFan);

        auto vertices = new VertexList(vertices = [
                vec3(-1,-1,-1),
                vec3(+1,-1,-1),
                vec3(-1,+1,-1),
                vec3(+1,+1,-1),
                vec3(-1,-1,1),
                vec3(+1,-1,1),
                vec3(-1,+1,1),
                vec3(+1,+1,1)
                ]);

        faces.setVertexList(vertices);
        faces.expandVertex();
        faces.generateFlatNormal();
        faces.generateTexcoord();
    }

}
