module model.xfile.node.XMeshTextureCoords;

import sbylib.math.Vector;

import model.xfile.node;

class XMeshTextureCoords : XNode {
    vec2[] uvArray;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMeshNormals(\n%suvArray: %s\n%s)".format(
            tab2,
            toStringArray(depth, this.uvArray),
            tab1
        );
    }
}
