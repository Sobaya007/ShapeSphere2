module model.xfile.node.XMeshNormals;

import sbylib.math.Vector;

import model.xfile.node;

struct XMeshNormals {
    vec3[] normals;
    uint[3][] indices; // indices.length == 「面の数」
}
