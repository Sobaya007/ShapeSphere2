module sbylib.entity.TypedEntity;

import sbylib.collision;

public {
    import sbylib.entity.Entity;
}

class TypedEntity(G, M) {

    import sbylib.utils.Functions;

    mixin Proxy;

    @Proxied Entity entity; //ShaderMaterialよりscaleとかが先に反応するように
    @Proxied TypedMesh!(G, M) mesh;

    alias entity this;
}

auto makeEntity(string file = __FILE__, int line = __LINE__) {
    return new Entity(file, line);
}

auto makeEntity(G, M)(G g, M m, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M);
    entity.entity = new Entity(file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity.entity);
    entity.entity.setMesh(entity.mesh);
    return entity;
}

auto makeEntity(CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    return new Entity(colGeom, file, line);
}

auto makeEntity(G, M)(G g, M m, CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M);
    entity.entity = new Entity(colGeom, file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity.entity);
    entity.entity.setMesh(entity.mesh);
    return entity;
}
