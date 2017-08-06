module model.xfile.node.XMaterialNode;

import sbylib.math.Vector;

import model.xfile.node;

class XMaterialNode : XNode {
    string name;
    vec4 faceColor;
    float power;
    vec3 specularColor;
    vec3 emissiveColor;
    XTextureFilenameNode textureFileName;

    override string toString() {
        return toString(0);
    }

    override string toString(int depth) {
        import std.format, std.range, std.array, std.functional;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XMaterialNode(\n%sname: %s,\n%sfaceColor: %s,\n%spower: %s,\n%sspecularColor: %s,\n%semissiveColor: %s,\n%stextureFileName: %s\n%s)".format(
            tab2,
            this.name,
            tab2,
            this.faceColor,
            tab2,
            this.power,
            tab2,
            this.specularColor,
            tab2,
            this.emissiveColor,
            tab2,
            this.textureFileName.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab1
        );
    }
}
