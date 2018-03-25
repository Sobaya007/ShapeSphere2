module game.console.selections.EntitySelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.MatrixSelection;
import game.console.selections.VectorSelection;

class EntitySelection : Selectable {

    private Selectable mParent;
    private Entity entity;

    this(Selectable parent, Entity entity) {
        this.mParent = parent;
        this.entity = entity;
    }

    mixin ImplCountChild!(true);

    override string name() {
        return entity.name;
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
        import std.algorithm : map;
        import std.array : array;

        return
            entity.getChildren.map!(e => cast(Selectable)new EntitySelection(this, e)).array
            ~ new VectorSelection!(true)(this, "pos", entity.pos) 
            ~ new MatrixSelection(this, "rot", entity.rot) 
            ~ new VectorSelection!(true)(this, "scale", entity.scale) ;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to Entity.";
    }
}

