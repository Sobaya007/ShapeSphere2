module model.xfile.loader.XGeometry;

import sbylib;

immutable class XGeometry {
immutable:
    vec3[] positions;
    vec3[] normals;
    vec2[] uvs;

    this(immutable(vec3[]) positions, immutable(vec3[]) normals, immutable(vec2[]) uvs) {
        this.positions = positions;
        this.normals = normals;
        this.uvs = uvs;
    }

    VertexNT[] buildVertices() {
        auto num = this.positions.length;
        VertexNT[] vertices = new VertexNT[num];
        foreach(i; 0..num) {
            vertices[i] = new VertexNT(
                this.positions[i],
                i < this.normals.length ? this.normals[i] : vec3(),
                i < this.uvs.length     ? this.uvs[i]     : vec2()
            );
        }
        return vertices;
    }

    string toString() {
        return toString(0);
    }

    string toString(int depth) {
        import std.format, std.range, std.array, std.algorithm, std.functional, std.conv;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XGeometry(\n%spositions: %s,\n%snormals: %s,\n%suvs: %s\n%s)".format(
            tab2,
            "[%s\n%s]".format(
                this.positions.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            ),
            tab2,
            "[%s\n%s]".format(
                this.normals.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            ),
            tab2,
            "[%s\n%s]".format(
                this.uvs.map!(a => "\n" ~ tab3 ~ a.to!string).join(", "),
                tab2
            ),
            tab1
        );
    }
}
