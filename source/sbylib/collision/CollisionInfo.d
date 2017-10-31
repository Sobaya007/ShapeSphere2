module sbylib.collision.CollisionInfo;

import sbylib.core.Entity;
import sbylib.math.Vector;

struct CollisionInfo {
    private Entity _entity;
    private Entity _entity2;

    this(Entity entity, Entity entity2) {
        this._entity = entity;
        this._entity2 = entity2;
    }

    Entity entity() {
        return this._entity;
    }

    Entity entity2() {
        return this._entity2;
    }
}

struct CollisionInfoRay {
    private Entity _entity;
    private CollisionRay _ray;
    private vec3 _point;

    this(Entity entity, CollisionRay ray, vec3 point) {
        this._entity = entity;
        this._ray = ray;
        this._point = point;
    }

    Entity entity() {
        return this._entity;
    }

    CollisionRay ray() {
        return this._ray;
    }

    vec3 point() {
        return this._point;
    }
}
