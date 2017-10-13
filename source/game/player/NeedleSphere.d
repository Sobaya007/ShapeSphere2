module game.player.NeedleSphere;

public import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.PlayerMaterial;
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
    private static immutable uint RECURSION_LEVEL = 2;
    private static immutable float DEFAULT_RADIUS = 0.5;

    NeedleParticle[] particleList;
    Player.PlayerEntity entity;
    private Player parent;
    private flim needleCount;
    private vec3 lVel;
    private vec3 aVel;

    this(Player parent) {
        this.parent = parent; 
        this.needleCount = flim(0,0,1);
        auto geom = Sphere.create(DEFAULT_RADIUS, RECURSION_LEVEL);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.entity = new Player.PlayerEntity(geom, mat, new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.particleList = entity.getMesh().geom.vertices.map!(p => new NeedleParticle(p.position)).array;
        NeedlePair[] pairs = this.generatePairs(geom, this.particleList);
        foreach(pair; pairs) {
            pair.p0.next ~= pair.p1;
            pair.p1.next ~= pair.p0;
        }
        foreach (p; particleList) {
            p.isStinger = p.next.all!(a => a.isStinger == false);
        }
    }

    void fromElastic(ElasticSphere elastic) {
        this.needleCount = 0;
        this.lVel = this.calcLinearVelocity();
        this.aVel = this.calcAngularVelocity();
        foreach (particle; this.particleList) {
            particle.initialize();
        }
        parent.world.add(entity);
        this.entity.obj.pos = elastic.entity.obj.pos;
    }

    override void move() {
        this.lVel.y -= GRAVITY * Player.TIME_STEP;
        this.lVel -= AIR_REGISTANCE * this.lVel * Player.TIME_STEP / MASS;
        this.collision();
        auto d = this.lVel * Player.TIME_STEP;
        this.entity.obj.pos += d;
        foreach (particle; this.particleList) {
            particle.position += d;
        }
        this.rotateParticles();
        foreach (particle; this.particleList) {
            particle.move();
        }
        updateGeometry();
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

    override Player.PlayerEntity getEntity() {
        return entity;
    }

    override void leave() {
        parent.world.remove(entity);
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
        return this.particleList.map!(p => p.velocity).sum / this.particleList.length;
    }

    private vec3 calcAngularVelocity() {
        return this.particleList.map!((p) {
            auto r = p.position - this.entity.obj.pos;
            auto v = p.velocity - this.lVel;
            return cross(r, v) / lengthSq(r);
        }).sum / this.particleList.length;
    }

    vec3 calcVelocity(vec3 pos) {
        auto r = pos - this.entity.obj.pos;
        return this.lVel + cross(this.aVel, r);
    }

    private float calcRadius() {
        auto center = this.entity.obj.pos;
        return this.particleList.map!(a => (a.position - center).length).sum / this.particleList.length;
    }

    private void rotateParticles() {
        auto center = this.entity.obj.pos;
        auto radius = this.calcRadius();
        quat rot = quat.axisAngle(this.aVel * Player.TIME_STEP);
        foreach (p; this.particleList) {
            p.position = rotate(p.position-center, rot) + center;
            p.normal = rotate(p.normal, rot);
        }
    }

    private NeedlePair[] generatePairs(const GeometryN geom, NeedleParticle[] particles) const {
        //隣を発見
        uint[2][] pairIndex;
        uint[2] makePair(uint a,uint b) {
            return a < b ? [a,b] : [b,a];
        }
        foreach (face; geom.faces) {
            auto idx0 = face.indexList[0];
            auto idx1 = face.indexList[1];
            auto idx2 = face.indexList[2];

            if (pairIndex.canFind(makePair(idx0,idx1)) == false) pairIndex ~= makePair(idx0,idx1);
            if (pairIndex.canFind(makePair(idx1,idx2)) == false) pairIndex ~= makePair(idx1,idx2);
            if (pairIndex.canFind(makePair(idx2,idx0)) == false) pairIndex ~= makePair(idx2,idx0);
        }
        return pairIndex.map!(pair => NeedlePair(particles[pair[0]], particles[pair[1]])).array;
    }

    private void updateGeometry() {
        auto geom = this.entity.getMesh().geom;
        auto vs = geom.vertices;
        foreach (ref v; vs) {
            v.normal = vec3(0);
        }
        foreach (face; geom.faces) {
            auto normal = normalize(cross(
                    vs[face.indexList[2]].position - vs[face.indexList[0]].position,
                    vs[face.indexList[1]].position - vs[face.indexList[0]].position));
            vs[face.indexList[0]].normal += normal;
            vs[face.indexList[1]].normal += normal;
            vs[face.indexList[2]].normal += normal;
        }
        foreach (i,v; vs) {
            auto p = this.particleList[i];
            v.normal = safeNormalize(v.normal);
            v.position = (this.entity.obj.viewMatrix * vec4(p.position, 1)).xyz;
        }
        geom.updateBuffer();
    }

    class NeedleParticle {
        vec3 position; /* in World, used for Render */
        vec3 velocity;
        vec3 normal; /* in World */
        vec3 force;
        bool isGround;
        bool isStinger;
        NeedleParticle[] next;
        Entity entity;
        CollisionCapsule capsule;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
            this.velocity = vec3(0,0,0);
            this.force = vec3(0,0,0);
            this.capsule = new CollisionCapsule(0.1, this.position, this.position);
            this.entity = new Entity(this.capsule);
        }

        void initialize() {
            //this.position = this.particle.position;
        }

        void move() {
           //this.particle.normal = normalize(this.position - entity.obj.pos);
           this.position = entity.obj.pos + this.normal * this.getLength(this.isStinger);
           this.force = vec3(0,0,0); //用済み
           this.capsule.setEnd(this.capsule.start);
           this.capsule.setStart(this.position);
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
            auto center = sphere.entity.obj.pos;
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

    struct NeedlePair {
        NeedleParticle p0, p1;

        this(NeedleParticle p0, NeedleParticle p1) {
            this.p0 = p0;
            this.p1 = p1;
        }
    }
}
