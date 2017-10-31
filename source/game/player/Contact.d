module game.player.Contact;

/*
import sbylib;

interface PhysicalObject {

    vec3 getCenter();
    ref vec3 linearVelocity();
    ref vec3 angularVelocity();
}

struct Contact {
    private PhysicalObject obj;
    private vec3 normal, tan, bin;
    private vec3 nTorque;
    private vec3 tTorque;
    private vec3 bTorque;
    private vec3 nTorqueUnit;
    private vec3 tTorqueUnit;
    private vec3 bTorqueUnit;
    private float normalDenominator;
    private float tanDenominator;
    private float binDenominator;
    private float targetNormalLinearVelocity;
    private float normalTotalImpulse;
    private float tanTotalImpulse;
    private float binTotalImpulse;

    this(CollisionInfo info, PhysicalObject obj) {
        this.obj = obj;
        auto geom = info.entity.getCollisionEntry().getGeometry();
        auto geom2 = info.entity2.getCollisionEntry().getGeometry();
        assert(cast(CollisionPolygon)geom !is null
                || cast(CollisionPolygon)geom2 !is null);
        auto polygon = cast(CollisionPolygon)geom;
        if (polygon is null) {
            polygon = cast(CollisionPolygon)geom2;
        }
        this.normal = polygon.normal;
        this.normalTotalImpulse = 0;
        this.tanTotalImpulse = 0;
        this.binTotalImpulse = 0;

        //tangentベクトルは物体間の相対速度から法線成分を抜いた方向
        auto center = obj.getCenter();
        auto colPoint = center - MAX_RADIUS * this.normal;
        auto colPointVel = this.calcVelocity(colPoint);
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
            dot(this.obj.linearVelocity, vec) + dot(torque, this.obj.angularVelocity);

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
            dot(this.obj.linearVelocity, vec) + dot(torque, this.obj.angularVelocity);
        return abs(calcColPointVel(normal, nTorque) - targetNormalLinearVelocity) < 1e-2;
    }

    vec3 calcVelocity(vec3 pos) {
        auto r = pos - this.obj.getCenter();
        return this.obj.linearVelocity + cross(this.obj.angularVelocity, r);
    }
}
*/
