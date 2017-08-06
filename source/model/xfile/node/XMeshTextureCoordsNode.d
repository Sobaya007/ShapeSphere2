module model.xfile.node.XMeshTextureCoordsNode;

import sbylib.math.Vector;

import model.xfile.node;

class XMeshTextureCoordsNode : XNode {
    vec2[] uvs;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMeshTextureCoordsNode(\n%suvs: %s\n%s)".format(
            tab2,
            toStringArray(depth, this.uvs),
            tab1
        );
    }
}
