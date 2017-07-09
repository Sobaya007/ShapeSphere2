module sbylib.collision.ICollidable;

public {
    import sbylib.mesh.Object3D;
    import sbylib.collision.CollisionInfo;
    import sbylib.collision.CollisionEntry;
    import sbylib.collision.geometry.CollisionRay;
}

interface ICollidable {

    CollisionInfo collide(CollisionEntry);
    CollisionInfoRay collide(CollisionRay);
    void setParent(Object3D);
    void setUserData(void*);
    void* getUserData();
    CollisionEntry[] search(bool delegate(CollisionEntry));
    CollisionEntry searchMin(float delegate(CollisionEntry));
}
