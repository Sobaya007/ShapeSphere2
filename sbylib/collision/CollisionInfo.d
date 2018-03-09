module sbylib.collision.CollisionInfo;

import sbylib.entity.Entity;
import sbylib.math.Vector;

struct CollisionInfo {
    private Entity _entity;
    private Entity _entity2;
    private float depth;
    private vec3 pushVector; //標準化したベクトルとする。depthをかけた状態で保存すると、depth = 0のときに情報が壊れる

    this(Entity entity, Entity entity2, float depth, vec3 pushVector) {
        this._entity = entity;
        this._entity2 = entity2;
        this.depth = depth;
        this.pushVector = pushVector;
    }

    Entity entity() {
        return this._entity;
    }

    Entity entity2() {
        return this._entity2;
    }

    float getDepth() {
        return depth;
    }

    Entity getOther(Entity me) {
        if (me is _entity) return _entity2;
        if (me is _entity2) return _entity;
        assert(false, _entity.name ~ " " ~ _entity2.name ~ " " ~ me.name);
    }

    vec3 getPushVector(Entity me) {
        if (me is _entity) return pushVector;
        if (me is _entity2) return -pushVector;
        assert(false);
    }
}

struct CollisionInfoByQuery {
    Entity entity;
    float depth;
    vec3 pushVector; //標準化したベクトルとする。depthをかけた状態で保存すると、depth = 0のときに情報が壊れる
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
