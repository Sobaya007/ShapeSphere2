module model.xfile.loader.XLeviathan;

import sbylib;

import model.xfile.loader;

class XLeviathan {
    XMaterial material;
    uint[] indices;

    override string toString() {
        return toString(0);
    }

    string toString(int depth) {
        import std.format, std.range, std.array, std.algorithm, std.functional, std.conv;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XLeviathan(\n%smaterial: %s,\n%sindices: %s\n%s)".format(
            tab2,
            this.material.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            "[%s\n%s]".format(
                this.indices.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            ),
            tab1
        );
    }
}
