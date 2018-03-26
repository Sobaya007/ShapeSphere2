module sbylib.model.xfile.node.XMeshNode;

import sbylib.math.Vector;

import sbylib.model.xfile.node;

class XMeshNode : XNode {
    vec3[] vertices;
    uint[3][] faces; // 三角ポリゴンのみに対応

    XMeshNormalsNode meshNormals;
    XMeshTextureCoordsNode meshTextureCoords;
    XMeshMaterialListNode meshMaterialList;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array, std.functional;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMeshNode(\n%svertices: %s,\n%sfaces: %s,\n%smeshNormals: %s,\n%smeshTextureCoords: %s,\n%smeshMaterialList: %s\n%s)".format(
            tab2,
            toStringArray(depth, this.vertices),
            tab2,
            toStringArray(depth, this.faces),
            tab2,
            this.meshNormals.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            this.meshTextureCoords.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            this.meshMaterialList.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab1
        );
    }
}
