module model.xfile.loader.XEntity;

import sbylib;

import model.xfile.loader;

class XEntity {

    XEntity[] children;
    XGeometry geometry;
    XLeviathan[] leviathans;

    /*
        XEntityをEntityに変換する。
            テスト用の関数なので実際のゲームでは用いない
    */
    Entity buildEntity() {
        return buildEntity(new DefaultMaterialBuilder);
    }

    Entity buildEntity(MaterialBuilder materialBuilder) {
        Entity entity = new Entity;
        foreach(child; this.children) {
            entity.addChild(child.buildEntity(materialBuilder));
        }
        if (this.geometry !is null) {
            VertexNT[] vertices = this.geometry.buildVertices();
            foreach(leviathan; this.leviathans) {
                entity.addChild(leviathan.buildEntity(vertices, materialBuilder));
            }
        }
        return entity;
    }

    override string toString() {
        return toString(0);
    }

    string toString(int depth) {
        import std.format, std.range, std.array, std.algorithm, std.functional, std.conv;
        string tab1 = '\t'.repeat(depth).array;
        string tab2 = '\t'.repeat(depth + 1).array;
        string tab3 = '\t'.repeat(depth + 2).array;

        return "XEntity(\n%schildren: %s,\n%sgeometry: %s,\n%sleviathans: %s\n%s)".format(
            tab2,
            "[%s\n%s]".format(
                this.children.map!(a => "\n" ~ tab3 ~ (a is null ? a.to!string : a.toString(depth + 2))).join(", "),
                tab2
            ),
            tab2,
            this.geometry.pipe!(a => a is null ? "null" : a.toString(depth + 1)),
            tab2,
            "[%s\n%s]".format(
                this.leviathans.map!(a => "\n" ~ tab3 ~ (a is null ? a.to!string : a.toString(depth + 2))).join(", "),
                tab2
            ),
            tab1
        );
    }

}
