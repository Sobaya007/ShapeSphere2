module model.xfile.node.XFrame;

import sbylib.math.Matrix;

import model.xfile.node;

class XFrame : XNode {
    string name;
    XFrameTransformMatrix frameTransformMatrix;

    XFrame[] frames; // children
    XMesh[] meshes;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array, std.functional;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XFrame(\n%sname: %s,\n%sframeTransformMatrix: %s,\n%sframes: %s,\n%smeshes: %s\n%s)".format(
            tab2,
            this.name,
            tab2,
            this.frameTransformMatrix.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            toStringArray(depth, this.frames),
            tab2,
            toStringArray(depth, this.meshes),
            tab1
        );
    }
}
