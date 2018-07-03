module sbylib.entity.TypedEntity;

import sbylib.collision;

public {
    import sbylib.entity.Entity;
}

class TypedEntity(G, M) : Entity {

    import sbylib.utils.Functions;

    mixin Proxy;

    @Proxied Object3D obj; //ShaderMaterialよりscaleとかが先に反応するように
    @Proxied TypedMesh!(G, M) mesh;

    this(Args...)(Args args) {
        super(args);
        this.obj = super.obj;
    }

    override string toString() {
        return "this is typed entity";
    }
}

auto makeEntity(string file = __FILE__, int line = __LINE__) {
    return new Entity(file, line);
}

auto makeEntity(G, M)(G g, M m, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M)(file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity);
    entity.setMesh(entity.mesh);
    return entity;
}

auto makeEntity(CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    return new Entity(colGeom, file, line);
}

auto makeEntity(G, M)(G g, M m, CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M)(colGeom, file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity);
    entity.setMesh(entity.mesh);
    return entity;
}
