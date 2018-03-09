module sbylib.model.xfile.node.XFrameNode;

import sbylib.math.Matrix;

import sbylib.model.xfile.node;

class XFrameNode : XNode {
    string name;
    XFrameTransformMatrixNode frameTransformMatrix;

    XFrameNode[] frames; // children
    XMeshNode mesh;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array, std.functional;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XFrameNode(\n%sname: %s,\n%sframeTransformMatrix: %s,\n%sframes: %s,\n%smesh: %s\n%s)".format(
            tab2,
            this.name,
            tab2,
            this.frameTransformMatrix.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            toStringArray(depth, this.frames),
            tab2,
            this.mesh.pipe!(a => (a is null ? "null" : a.toString(depth + 1))),
            tab1
        );
    }
}
