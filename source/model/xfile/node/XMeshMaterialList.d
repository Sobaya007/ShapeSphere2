module model.xfile.node.XMeshMaterialList;

import model.xfile.node;

struct XMeshMaterialList {
    XMaterial[] materials;
    uint[] indices; // indices.length == 「面の数」
}
