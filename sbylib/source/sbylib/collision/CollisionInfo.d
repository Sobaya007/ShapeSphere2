module sbylib.collision.CollisionInfo;

import sbylib.entity.Entity;
import sbylib.math.Vector;

struct CollisionInfo {
    private Entity mEntity;
    private Entity mEntity2;
    private float depth;
    private vec3 pushVector; //標準化したベクトルとする。depthをかけた状態で保存すると、depth = 0のときに情報が壊れる

    this(Entity entity, Entity entity2, float depth, vec3 pushVector) {
        this.mEntity = entity;
        this.mEntity2 = entity2;
        this.depth = depth;
        this.pushVector = pushVector;
    }

    Entity entity() {
        return this.mEntity;
    }

    Entity entity2() {
        return this.mEntity2;
    }

    float getDepth() {
        return depth;
    }

    Entity getOther(Entity me) {
        if (me is mEntity) return mEntity2;
        if (me is mEntity2) return mEntity;
        assert(false, mEntity.name ~ " " ~ mEntity2.name ~ " " ~ me.name);
    }

    vec3 getPushVector(Entity me) {
        if (me is mEntity) return pushVector;
        if (me is mEntity2) return -pushVector;
        assert(false);
    }
}

struct CollisionInfoByQuery {
    Entity entity;
    float depth;
    vec3 pushVector; //標準化したベクトルとする。depthをかけた状態で保存すると、depth = 0のときに情報が壊れる
}

struct CollisionInfoRay {
    private Entity mEntity;
    private CollisionRay mRay;
    private vec3 mPoint;

    this(Entity entity, CollisionRay ray, vec3 point) {
        this.mEntity = entity;
        this.mRay = ray;
        this.mPoint = point;
    }

    Entity entity() {
        return this.mEntity;
    }

    CollisionRay ray() {
        return this.mRay;
    }

    vec3 point() {
        return this.mPoint;
    }
}
