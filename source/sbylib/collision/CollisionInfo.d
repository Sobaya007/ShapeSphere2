module sbylib.collision.CollisionInfo;

import sbylib.core.Entity;
import sbylib.math.Vector;
import std.variant;
import sbylib.collision.detect;

struct CollisionInfo {
    private Entity[2] entity;
    private CollisionResult[2] result;

    this(Entity[2] entity, CollisionResult[2] result) {
        this.entity = entity;
        this.result = result;
    }

    Entity getOtherEntity(Entity me) {
        if (entity[0] is me) return entity[1];
        if (entity[1] is me) return entity[0];
        assert(false);
    }

    CollisionResult getMyResult(Entity me) {
        if (entity[0] is me) return result[0];
        if (entity[1] is me) return result[1];
        assert(false);
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
