module game.player.NeedleSphere;

public import game.player.BaseSphere;
import game.player.PlayerMaterial;
import game.player.Particle;
import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class NeedleSphere : BaseSphere {

    private static immutable FRICTION = 2.0f;
    private static immutable RADIUS = 2.0f;
    private static immutable ALLOWED_PENETRATION = 0.5f;
    private static immutable SEPARATION_COEF = 0.5f / Player.TIME_STEP;
    private static immutable RESTITUTION_RATE = 0.3f;
    private static immutable MASS = 1.0f;
    private static immutable AIR_REGISTANCE = 0.5f;
    private static immutable GRAVITY = 30.0f;

    private static immutable MASS_INV = 1.0f / MASS;
    private static immutable INERTIA_INV = 2.5 / (MASS * RADIUS * RADIUS);

    private Player parent;
    private flim needleCount;
    private NeedleParticle[] particleList;
    private vec3 lVel;
    private vec3 aVel;
    private Entity entity;

    this(Player parent) {
        this.parent = parent; 
        this.needleCount = flim(0,0,1);
        this.particleList = parent.particleList.map!(p => new NeedleParticle(p)).array;
        this.entity = new Entity(new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.parent.entity.addChild(this.entity);
    }

    void initialize() {
        this.needleCount = 0;
        this.lVel = this.calcLinearVelocity();
        this.aVel = this.calcAngularVelocity();
        foreach (particle; this.particleList) {
            particle.initialize();
        }
    }

    override void move() {
        this.lVel.y -= GRAVITY * Player.TIME_STEP;
        this.lVel -= AIR_REGISTANCE * this.lVel * Player.TIME_STEP / MASS;
        this.collision();
        auto d = this.lVel * Player.TIME_STEP;
        this.parent.entity.obj.pos += d;
        foreach (particle; this.particleList) {
            particle.position += d;
        }
        this.rotateParticles();
        foreach (particle; this.particleList) {
            particle.move();
        }
    }

    override void onDownPress() {}
    override void onDownJustRelease() {}
    override void onLeftPress() {}
    override void onRightPress() {}
    override void onForwardPress() {}
    override void onBackPress() {}

    override void onNeedlePress() {
        this.needleCount += 0.1;
    }
    override void onNeedleRelease(){
        this.needleCount -= 0.3;
    }

    bool hasFinished() {
        return this.needleCount == 0;
    }

    private void collision() {
        auto colInfos = Array!CollisionInfo(0);
        scope (exit) colInfos.destroy();
        this.parent.floors.collide(colInfos, this.entity);
        auto contacts = Array!Contact(0);
        scope (exit) contacts.destroy();
        foreach (colInfo; colInfos) {
            if (!colInfo.collided) continue;
            auto contact = Contact(colInfo, this);
            contacts ~= contact;
        }
        foreach (i; 0..3) {
            foreach (contact; contacts) {
                contact.solve();
            }
        }
    }

    private vec3 calcLinearVelocity() {
        return this.particleList.map!(p => p.particle.velocity).sum / this.particleList.length;
    }

    private vec3 calcAngularVelocity() {
        return this.particleList.map!((p) {
            auto r = p.particle.position - this.parent.entity.obj.pos;
            auto v = p.particle.velocity - this.lVel;
            return cross(r, v) / lengthSq(r);
        }).sum / this.particleList.length;
    }

    vec3 calcVelocity(vec3 pos) {
        auto r = pos - this.parent.entity.obj.pos;
        return this.lVel + cross(this.aVel, r);
    }

    private float calcRadius() {
        auto center = this.parent.entity.obj.pos;
        return this.parent.particleList.map!(a => (a.position - center).length).sum / this.parent.particleList.length;
    }

    private void rotateParticles() {
        auto center = this.parent.entity.obj.pos;
        auto radius = this.calcRadius();
        quat rot = quat.axisAngle(this.aVel * Player.TIME_STEP);
        foreach (p; this.particleList) {
            p.position = rotate(p.position-center, rot) + center;
            p.particle.normal = rotate(p.particle.normal, rot);
        }
    }

    class NeedleParticle {
        Particle particle;
        vec3 position;

        this(Particle particle) {
            this.particle = particle;
        }

        void initialize() {
            this.position = this.particle.position;
        }

        void move() {
           //this.particle.normal = normalize(this.position - parent.entity.obj.pos);
           this.particle.position = parent.entity.obj.pos + this.particle.normal * this.getLength(this.particle.isStinger);
           this.particle.force = vec3(0,0,0); //用済み
           this.particle.capsule.setEnd(this.particle.capsule.start);
           this.particle.capsule.setStart(this.particle.position);
        }

        private float getLength(bool isNeedle){
            alias t = needleCount;
            const minLength = RADIUS * 0.7;
            auto maxLength = isNeedle ? RADIUS : RADIUS * 0.5;
            return t * (maxLength - minLength) + minLength;
        }
    }

    struct Contact {
        NeedleSphere sphere;
        vec3 normal, tan, bin;
        vec3 nTorque;
        vec3 tTorque;
        vec3 bTorque;
        vec3 nTorqueUnit;
        vec3 tTorqueUnit;
        vec3 bTorqueUnit;
        float normalDenominator;
        float tanDenominator;
        float binDenominator;
        float targetNormalLinearVelocity;
        float normalTotalImpulse;
        float tanTotalImpulse;
        float binTotalImpulse;

        this(CollisionInfo info, NeedleSphere sphere) {
            this.sphere = sphere;
            assert(cast(CollisionPolygon)info.colEntry.getGeometry() !is null
                    || cast(CollisionPolygon)info.colEntry2.getGeometry() !is null);
            auto polygon = cast(CollisionPolygon)info.colEntry.getGeometry();
            if (polygon is null) {
                polygon = cast(CollisionPolygon)info.colEntry2.getGeometry();
            }
            this.normal = polygon.normal;
            this.normalTotalImpulse = 0;
            this.tanTotalImpulse = 0;
            this.binTotalImpulse = 0;

            //tangentベクトルは物体間の相対速度から法線成分を抜いた方向
            auto center = sphere.parent.entity.obj.pos;
            auto colPoint = center - RADIUS * this.normal;
            auto colPointVel = sphere.calcVelocity(colPoint);
            auto relativeColPointVel = colPointVel;
            auto relativeColPointVelNormal = dot(relativeColPointVel, normal);
            this.tan = normalize(relativeColPointVel - relativeColPointVelNormal * normal);
            if (tan.hasNaN) { //normalizeに失敗したら適当にnormalと垂直になるように作る
                tan = vec3(normal.y * normal.x - normal.z * normal.z,
                         -normal.z * normal.y - normal.x * normal.x,
                        normal.x * normal.z + normal.y * normal.y)
                .normalize;
            }
            assert(tan.hasNaN == false);
            //binはnormal・tanと垂直
            this.bin = cross(normal, tan).normalize;

            auto colPointFrom = colPoint - center;
            nTorque = cross(colPointFrom, normal);
            tTorque = cross(colPointFrom, tan);
            bTorque = cross(colPointFrom, bin);
            nTorqueUnit = INERTIA_INV * nTorque;
            tTorqueUnit = INERTIA_INV * tTorque;
            bTorqueUnit = INERTIA_INV * bTorque;

            alias calcDenom = (vec, torqueUnit) =>
                1 / (MASS_INV + dot(vec, cross(torqueUnit, colPointFrom)));
            normalDenominator = calcDenom(normal, nTorqueUnit);
            tanDenominator    = calcDenom(tan,    tTorqueUnit);
            binDenominator    = calcDenom(bin,    bTorqueUnit);

            //if (nvel > -0.02) {
            //    nvel = 0;
            //}

            auto penetration = dot(this.normal, polygon.positions[0] - colPoint) - ALLOWED_PENETRATION; //ちょっと甘くする
            auto restitutionVelocity = -RESTITUTION_RATE * relativeColPointVelNormal;
            auto separationVelocity = penetration * SEPARATION_COEF;
            this.targetNormalLinearVelocity = max(restitutionVelocity, separationVelocity);
        }

        void solve() {
            alias calcColPointVel = (vec, torque) =>
                dot(this.sphere.lVel, vec) + dot(torque, this.sphere.aVel);

            //法線方向の速度についての拘束
            //衝突点における法線方向の相対速度をtargetnormallinearvelocityにする
            //ただし 法線方向撃力 > 0
            //物体間に働く力は必ず斥力だから。
            auto colPointVelNormal = calcColPointVel(normal, nTorque);
            auto oldNormalImpulse = normalTotalImpulse;
            auto newNormalImpulse = (targetNormalLinearVelocity - colPointVelNormal) * normalDenominator;

            this.normalTotalImpulse += newNormalImpulse;
            if (normalTotalImpulse < 0) normalTotalImpulse = 0; //条件
            newNormalImpulse = normalTotalImpulse - oldNormalImpulse; //補正

            auto normalImpulseVector = normal * newNormalImpulse;
            sphere.lVel += MASS_INV * normalImpulseVector;
            sphere.aVel += nTorqueUnit * newNormalImpulse;

            //摩擦力を与える
            //摩擦力は基本的に相対速度を0にする撃力
            //ただし摩擦力 < friction * 法線方向の撃力
            auto colPointVelTan = calcColPointVel(tan, tTorque);
            auto oldTanImpulse  = tanTotalImpulse;
            auto newTanImpulse  = -colPointVelTan * tanDenominator;
            this.tanTotalImpulse += newTanImpulse;

            auto colPointVelBin = calcColPointVel(bin, bTorque);
            auto oldBinImpulse  = binTotalImpulse;
            auto newBinImpulse  = -colPointVelBin * binDenominator;
            this.binTotalImpulse += newBinImpulse;

            auto maxFrictionSq     = abs(FRICTION * normalTotalImpulse) ^^ 2;
            auto currentFrictionSq = tanTotalImpulse^^2 + binTotalImpulse^^2;
            if (maxFrictionSq < currentFrictionSq) { //条件
                auto scale = sqrt(maxFrictionSq / currentFrictionSq);
                this.tanTotalImpulse *= scale;
                this.binTotalImpulse *= scale;
            }

            newTanImpulse = tanTotalImpulse - oldTanImpulse; //補正
            newBinImpulse = binTotalImpulse - oldBinImpulse; //補正

            auto frictionImpulseVector = tan * newTanImpulse + bin * newBinImpulse;
            sphere.lVel += MASS_INV * frictionImpulseVector;
            sphere.aVel += tTorqueUnit * newTanImpulse + bTorqueUnit * newBinImpulse;
        }

        bool hasFinished() {
            alias calcColPointVel = (vec, torque) =>
                dot(sphere.lVel, vec) + dot(torque, sphere.aVel);
            return abs(calcColPointVel(normal, nTorque) - targetNormalLinearVelocity) < 1e-2;
        }
    }
}
