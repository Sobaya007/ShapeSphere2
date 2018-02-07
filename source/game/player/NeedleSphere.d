module game.player.NeedleSphere;

public import game.player.BaseSphere;
import game.stage.Map;
import game.Game;
import game.player.ElasticSphere;
import game.player.PlayerMaterial;
import game.player.Player;
import game.camera.CameraController;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class NeedleSphere : BaseSphere {

    struct Wall {
        float allowedPenetration;
        float normalImpulseMin;
    }

    private static immutable {
        float FRICTION = 2.0f;
        float MAX_RADIUS = 1.5f;
        float DEFAULT_RADIUS = 1.0f;
        float MIN_RADIUS = 0.7f;
        Wall NORMAL_WALL = Wall(0.05f, 0f);
        Wall SAND_WALL = Wall(0.5f, -0.3f);
        float MAX_PENETRATION = 0.1f;
        float SEPARATION_COEF = 1f / Player.TIME_STEP;
        float RESTITUTION_RATE = 0.3f;
        float MASS = 1.0f;
        float AIR_REGISTANCE = 0.5f;
        float GRAVITY = 30.0f;

        float MASS_INV = 1.0f / MASS;
        float INERTIA_INV = 2.5 / (MASS * MAX_RADIUS * MAX_RADIUS);
        uint RECURSION_LEVEL = 2;
        float MAX_VELOCITY = 20;
    }

    private NeedleParticle[] particleList;
    private Player.PlayerEntity entity;
    private Player parent;
    private flim needleCount;
    private vec3 lVel;
    private vec3 aVel;
    private vec3 _lastDirection;
    private Maybe!vec3 contactNormal;
    private Entity line;

    alias parent this;

    this(Player parent, CameraController camera) {
        this.parent = parent; 
        this.needleCount = flim(0,0,1);
        auto geom = Sphere.create(DEFAULT_RADIUS, RECURSION_LEVEL);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.entity = makeEntity(geom, mat, new CollisionCapsule(MAX_RADIUS, vec3(0), vec3(0)));
        this.particleList = entity.geom.vertices.map!(p => new NeedleParticle(p.position)).array;
        NeedlePair[] pairs = this.generatePairs(geom, this.particleList);
        foreach(pair; pairs) {
            pair.p0.next ~= pair.p1;
            pair.p1.next ~= pair.p0;
        }
        foreach (p; particleList) {
            p.isStinger = p.next.all!(a => a.isStinger == false);
        }
        auto cmat = new ColorMaterial;
        cmat.color = vec4(1,0,0,1);
        this.line = new Entity(Capsule.create(0.1, vec3(0), vec3(0,3,0)), cmat);
        this.line.visible = false;
        this.entity.addChild(this.line);
    }

    void initialize(ElasticSphere elasticSphere) {
        this.needleCount = 0;
        this.entity.obj.pos = elasticSphere.getCenter();
        this.lVel = elasticSphere.getLinearVelocity();
        this.aVel = elasticSphere.getAngularVelocity();
        Game.getWorld3D().add(this.entity);
        this._lastDirection = elasticSphere.lastDirection;
    }

    override vec3 getCenter() {
        return this.entity.obj.pos;
    }

    override void setCenter(vec3 center) {
        this.entity.pos = center;
    }

    override void move() {
        if (this.contactNormal.isNone) {
            this.lVel.y -= GRAVITY * Player.TIME_STEP;
        }
        this.lVel -= AIR_REGISTANCE * this.lVel * Player.TIME_STEP / MASS;
        if (this.lVel.length > MAX_VELOCITY) this.lVel *= MAX_VELOCITY / this.lVel.length;
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

    override vec3 getCameraTarget() {
        return this.entity.pos;
    }

    override vec3 lastDirection() {
        return this._lastDirection;
    }

    override void onNeedlePress() {
        this.needleCount += 0.08;
    }
    override void onNeedleRelease(){
        if (this.needleCount == 0) {
            this.entity.remove();
            auto elasticSphere = parent.transit!ElasticSphere;
            elasticSphere.initialize(this);
            return;
        }
        this.needleCount -= 0.05;
    }

    override void onMovePress(vec2 v) {
        this.lVel += mat3.rotFromTo(vec3(0,1,0), this.contactNormal.getOrElse(vec3(0,1,0))) * this.camera.rot * vec3(v.x, 0, v.y) * 0.8;
    }

    private void collision() {
        auto colInfos = Array!CollisionInfo(0);
        scope (exit) colInfos.destroy();
        Game.getMap().getPolygon().collide(colInfos, this.entity);
        auto contacts = Array!Contact(0);
        scope (exit) contacts.destroy();
        auto lastContactNormal = this.contactNormal;
        this.contactNormal = None!vec3;
        Maybe!size_t newWallIndex;
        Maybe!size_t lastWallIndex;
        foreach (i, colInfo; colInfos) {
            contacts ~= Contact(colInfo, this);
            auto matName = colInfo.getOther(this.entity).getUserData!(string).getOrElse("");
            import std.algorithm;
            this.entity.getRootParent.traverse!((Entity e) {
                import std.stdio;
                writeln(e.getUserData!(string));
            });
            if (matName.canFind("Sand")) {
                auto nc = normalize(colInfo.getPushVector(this.entity));
                if (this.contactNormal.isNone || nc.y < this.contactNormal.y) {
                    this.contactNormal = Just(nc);
                    if (this.contactNormal != lastContactNormal) {
                        newWallIndex = Just(i);
                    } else {
                        lastWallIndex = Just(i);
                    }
                }
            }
        }
        if (newWallIndex.isJust) {
            contacts[newWallIndex.get].wall = SAND_WALL;
        } else if (lastWallIndex.isJust) {
            contacts[lastWallIndex.get].wall = SAND_WALL;
        }
        foreach (ref c; contacts) {
            c.initialize();
        }
        foreach (i; 0..10) {
            foreach (contact; contacts) {
                contact.solve();
            }
        }
    }

    vec3 calcVelocity(vec3 pos) {
        auto r = pos - this.entity.obj.pos;
        return this.lVel + cross(this.aVel, r);
    }

    private float calcRadius() {
        vec3 center = this.entity.obj.pos;
        return this.particleList.map!(a => (a.position - center).length).sum / this.particleList.length;
    }

    private void rotateParticles() {
        vec3 center = this.entity.obj.pos;
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
        auto geom = this.entity.geom;
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
            v.position = p.position;
        }
        geom.updateBuffer();
    }

    class NeedleParticle {
        vec3 position; /* in World, used for Render */
        vec3 normal; /* in World */
        vec3 force;
        bool isGround;
        bool isStinger;
        NeedleParticle[] next;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
            this.force = vec3(0,0,0);
        }

        void move() {
           //this.particle.normal = normalize(this.position - entity.obj.pos);
            this.position = this.normal * this.getLength(this.isStinger);
           this.force = vec3(0,0,0); //用済み
        }

        private float getLength(bool isNeedle){
            alias t = needleCount;
            auto maxLength = isNeedle ? MAX_RADIUS : MIN_RADIUS;
            return t * (maxLength - DEFAULT_RADIUS) + DEFAULT_RADIUS;
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
        CollisionInfo info;
        Wall wall;

        this(CollisionInfo info, NeedleSphere sphere) {
            this.info = info;
            this.sphere = sphere;
            this.wall = NORMAL_WALL;
        }

        void initialize() {
            this.normal = info.getPushVector(sphere.entity);
            this.normalTotalImpulse = 0;
            this.tanTotalImpulse = 0;
            this.binTotalImpulse = 0;

            //tangentベクトルは物体間の相対速度から法線成分を抜いた方向
            vec3 center = sphere.entity.obj.pos;
            auto colPoint = center - MAX_RADIUS * this.normal;
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

            auto penetration = info.getDepth - wall.allowedPenetration; //ちょっと甘くする
            penetration = min(penetration, MAX_PENETRATION); //大きく埋まりすぎていると吹っ飛ぶ
            auto separationVelocity = penetration * SEPARATION_COEF;
            auto restitutionVelocity = 0;//-RESTITUTION_RATE * relativeColPointVelNormal;
            this.targetNormalLinearVelocity = separationVelocity;//max(0, separationVelocity);//max(restitutionVelocity, separationVelocity);
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
            auto borderNormalImpulse = wall.normalImpulseMin;
            normalTotalImpulse = max(normalTotalImpulse, borderNormalImpulse);
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
//            if (maxFrictionSq < currentFrictionSq) { //条件
//                auto scale = sqrt(maxFrictionSq / currentFrictionSq);
//                this.tanTotalImpulse *= scale;
//                this.binTotalImpulse *= scale;
//            }

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
