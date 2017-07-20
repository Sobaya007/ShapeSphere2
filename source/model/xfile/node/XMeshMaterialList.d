module model.xfile.node.XMeshMaterialList;

import model.xfile.node;

class XMeshMaterialList : XNode {
    XMaterial[] materials;
    uint[] indices; // indices.length == 「面の数」

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMeshMaterialList(\n%smaterials: %s,\n%sindices: %s\n%s)".format(
            tab2,
            toStringArray(depth, this.materials),
            tab2,
            this.indices,
            tab1
        );
    }
}
