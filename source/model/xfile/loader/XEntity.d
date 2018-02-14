module model.xfile.loader.XEntity;

import sbylib;

import model.xfile.loader;

immutable class XEntity {
immutable:

    immutable(XEntity)[] children;
    Maybe!(immutable(XGeometry)) geometry;
    immutable(XLeviathan)[] leviathans;

    this(immutable(XEntity[]) children) {
        this.children = children;
        this.geometry = None!(immutable(XGeometry));
        this.leviathans = null;
    }

    this(immutable(XGeometry) geometry, immutable(XLeviathan)[] leviathans) {
        this.children = null;
        this.geometry = Just(geometry);
        this.leviathans = leviathans;
    }

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
        if (this.geometry.isJust) {
            VertexNT[] vertices = this.geometry.get().buildVertices();
            auto vertexGroup = new VertexGroupNT(vertices);
            foreach(leviathan; this.leviathans) {
                entity.addChild(leviathan.buildEntity(vertexGroup, materialBuilder));
            }
        }
        return entity;
    }

    string toString() {
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
                this.children.map!(a => "\n" ~ tab3 ~ a.toString(depth + 2)).join(", "),
                tab2
            ),
            tab2,
            this.geometry.pipe!(a => a.fmap!((immutable(XGeometry) a) => a.toString(depth+1)).getOrElse("null")),
            tab2,
            "[%s\n%s]".format(
                this.leviathans.map!(a => "\n" ~ tab3 ~ a.toString(depth + 2)).join(", "),
                tab2
            ),
            tab1
        );
    }

}
