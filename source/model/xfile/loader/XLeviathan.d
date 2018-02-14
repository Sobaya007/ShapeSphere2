module model.xfile.loader.XLeviathan;

import sbylib;

import model.xfile.loader;

immutable class XLeviathan {
immutable:
    XMaterial material;
    uint[] indices;

    this(immutable(XMaterial) material, immutable(uint[]) indices) {
        this.material = material;
        this.indices = indices;
    }

    Entity buildEntity(VertexGroupNT vertexGroup, MaterialBuilder materialBuilder) {
        import std.range, std.array;
        auto faceGroup = new FaceGroup!(Prim.Triangle)(this.indices);
        Geometry geometry = new GeometryNT(vertexGroup, faceGroup);
        Material material = materialBuilder.buildMaterial(this.material);
        return new Entity(geometry, material);
    }

    string toString() {
        return toString(0);
    }

    string toString(int depth) {
        import std.format, std.range, std.array, std.algorithm, std.functional, std.conv;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XLeviathan(\n%smaterial: %s,\n%sindices: %s\n%s)".format(
            tab2,
            this.material.pipe!(a => material.toString(depth+1)),
            tab2,
            "[%s\n%s]".format(
                this.indices.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            ),
            tab1
        );
    }
}
