module model.xfile.node.XNode;

import sbylib.math.Matrix;

import model.xfile.node;

abstract class XNode {
    string toString(int depth);

    string toStringArray(T)(int depth, T[] ary) {
        import std.format, std.range, std.array, std.algorithm, std.traits, std.conv;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        static if (isAssignable!(XNode, T)) {
            return "[%s\n%s]".format(
                ary.map!(a => "\n" ~ tab3 ~ (a is null ? a.to!string : a.toString(depth + 2))).join(", "),
                tab2
            );
        } else {
            return "[%s\n%s]".format(
                ary.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            );
        }
    }
}
