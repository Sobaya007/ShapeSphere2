module model.xfile.node.XMesh;

import sbylib.math.Vector;

import model.xfile.node;

struct XMesh {
    vec3[] vertices;
    uint[3][] faces; // 三角ポリゴンのみに対応

    XMeshNormals meshNormals;
    XMeshTextureCoords meshTextureCoords;
    XMeshMaterialList meshMaterialList;
}
