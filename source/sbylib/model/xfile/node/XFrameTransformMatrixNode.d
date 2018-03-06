module sbylib.model.xfile.node.XFrameTransformMatrixNode;

import sbylib.math.Matrix;

import sbylib.model.xfile.node;

class XFrameTransformMatrixNode : XNode {
    mat4 matrix;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array, std.string, std.algorithm;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XFrameTransformMatrixNode(\n%smatrix: %s\n%s)".format(
            tab2,
            "(%s\n%s)".format(
                this.matrix.toString.splitLines.map!(str => "\n" ~ tab2 ~ str).dropOne.join,
                tab2
            ),
            tab1
        );
    }
}
