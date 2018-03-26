module sbylib.model.xfile.node.XTextureFilenameNode;

import sbylib.model.xfile.node;

class XTextureFilenameNode : XNode {
    string name;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XTextureFilenameNode(\n%sname: %s\n%s)".format(
            tab2,
            this.name,
            tab1
        );
    }
}
