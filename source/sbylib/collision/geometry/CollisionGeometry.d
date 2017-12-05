module sbylib.collision.geometry.CollisionGeometry;

public {
    import sbylib.entity.Entity;
}

interface CollisionGeometry {
    void setOwner(Entity);
}
