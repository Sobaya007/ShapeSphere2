module game.console.selections.EntitySelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.MatrixSelection;
import game.console.selections.VectorSelection;

class EntitySelection : Selectable {

    private Entity entity;

    this(Entity entity) {this.entity = entity;}

    mixin ImplCountChild!(true);

    override string name() {
        return entity.name;
    }

    override Selectable[] childs() {
        import std.algorithm : map;
        import std.array : array;

        return
            entity.getChildren.map!(e => cast(Selectable)new EntitySelection(e)).array
            ~ new VectorSelection!(true)("pos", entity.pos) 
            ~ new MatrixSelection("rot", entity.rot) 
            ~ new VectorSelection!(true)("scale", entity.scale) ;
    }

    override string getInfo() {
        import std.algorithm : sort, group, map;
        import std.format;
        import std.array : join, split, array;

        return childs
            .sort!"a.name < b.name".array
            .group!"a.name==b.name"
            .map!(p => p[1] == 1 ? format!"%s(%d)"(p[0].name, p[0].countChilds): format!"%s[%d]"(p[0].name, p[1]))
            .join("\n");
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to Entity.";
    }
}

