module sbylib.model.xfile.node.XMeshNormalsNode;

import sbylib.math.Vector;

import sbylib.model.xfile.node;

class XMeshNormalsNode : XNode {
    vec3[] normals;
    uint[3][] indices; // indices.length == 「面の数」

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMeshNormalsNode(\n%snormals: %s,\n%sindices: %s\n%s)".format(
            tab2,
            toStringArray(depth, this.normals),
            tab2,
            toStringArray(depth, this.indices),
            tab1
        );
    }
}
