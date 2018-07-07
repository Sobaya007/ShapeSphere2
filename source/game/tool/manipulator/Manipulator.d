module game.tool.manipulator.Manipulator;

import sbylib;
import game.tool.manipulator;

import std.math;
import std.stdio;

class Manipulator {
    static string name = "manipulator";
    enum Axis {X, Y, Z}

public:
    Entity entity;

private:
    Entity target;
    vec3 initTargetPos;
    vec3 initRayPos;
    vec3 axisDir;

public:
    this() {
        buildEntity();
    }

    void setTarget(Entity target) in {
        assert(target.getUserData!Axis("Axis").isNone);
    } body {
        this.target = target;
        this.entity.pos = target.worldPos.get;
    }

    void setAxis(Entity axis) in {
        assert(axis.getUserData!Axis("Axis").isJust);
    } body {
        final switch(axis.getUserData!Axis("Axis").unwrap()) {
            case Axis.X: this.axisDir = vec3(1, 0, 0); break;
            case Axis.Y: this.axisDir = vec3(0, 1, 0); break;
            case Axis.Z: this.axisDir = vec3(0, 0, 1); break;
        }
    }

    bool setRay(CollisionRay ray) {
        if (this.target is null) return false;

        float dist;
        vec3 q1, q2;
        if (!calcNearestDistAndPos(this.target.worldPos.get, this.axisDir, ray.start, ray.dir, dist, q1, q2)) {
            return false;
        }

        this.initTargetPos = this.target.pos.get;
        this.initRayPos = q1;
        return true;
    }

    void updateRay(CollisionRay ray) {
        float dist;
        vec3 q1, q2;
        if (!calcNearestDistAndPos(this.initRayPos, this.axisDir, ray.start, ray.dir, dist, q1, q2)) {
            return;
        }

        this.target.pos = this.initTargetPos + (q1 - this.initRayPos);
        this.entity.pos = this.target.worldPos.get;
    }

private:
    void buildEntity() {
        this.entity = new Entity;

        this.entity.addChild(createArrow(vec3(1, 0, 0), vec3(0.6, 0.1, 0.1), Axis.X));
        this.entity.addChild(createArrow(vec3(0, 1, 0), vec3(0.1, 0.6, 0.1), Axis.Y));
        this.entity.addChild(createArrow(vec3(0, 0, 1), vec3(0.1, 0.1, 0.6), Axis.Z));

        this.entity.buildBVH();
    }

    Entity createArrow(vec3 direction, vec3 diffuse, Axis axis) {
        auto arrow = makeEntity(Pole.create(0.2, 10, 16), new LambertMaterial);
        auto head = makeEntity(Pole.create(0.4, 0.5, 16), new LambertMaterial);

        head.pos = vec3(0, 10/2.0, 0);
        arrow.addChild(head);
        arrow.rot = mat3.rotFromTo(vec3(0, 1, 0), direction);

        arrow.ambient = vec3(0.2, 0.2, 0.2);
        head.ambient = vec3(0.2, 0.2, 0.2);
        arrow.diffuse = diffuse;
        head.diffuse = diffuse;

        arrow.traverse((Entity e) {
            e.name = this.name;
            e.setUserData("Axis", axis);
        });

        return arrow;
    }

    // 2直線の最短距離と最短点を求める
    bool calcNearestDistAndPos(vec3 p1, vec3 v1, vec3 p2, vec3 v2, out float dist, out vec3 q1, out vec3 q2) {
        assert(v1.length > 0);
        assert(v2.length > 0);

        v1 = v1.normalize;
        v2 = v2.normalize;

        float d1 = dot(p2 - p1, v1);
        float d2 = dot(p2 - p1, v2);
        float dv = dot(v1, v2);

        if (dv.abs > 1.0 - 1e-5) {
            // 平行
            return false;
        }

        float t1 = (d1 - d2*dv) / (1.0 - dv*dv);
        float t2 = (d2 - d1*dv) / (dv*dv - 1.0);

        q1 = p1 + t1*v1;
        q2 = p2 + t2*v2;
        dist = (q2 - q1).length;

        return true;
    }


}
