module game.player.ElasticSphere;

public import game.player.BaseSphere;
public import game.player.NeedleSphere;
import game.player.PlayerMaterial;
import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class ElasticSphere : BaseSphere{


    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        uint RECURSION_LEVEL = 2;
        float DEFAULT_RADIUS = 0.5;
        float RADIUS = 2.0f;
        float MASS = 0.05;
        float FRICTION = 0.3;
        float ZETA = 0.5;
        float OMEGA = 100;
        float c = 2 * ZETA * OMEGA * MASS;
        float k = MASS * OMEGA * OMEGA;
        float GRAVITY = 100;
        uint ITERATION_COUNT = 20;

        float VEL_COEF = 1 / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float POS_COEF = - (TIME_STEP*k/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float FORCE_COEF = (TIME_STEP/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float BALOON_COEF = 20000;
        float DOWN_PUSH_FORCE = 600;
        float DOWN_PUSH_FORE_MIN = 800;
        float SIDE_PUSH_FORCE = 10;
    }

    ElasticParticle[] particleList;
    private ElasticPair[] pairList;
    Player.PlayerEntity entity;
    private flim pushCount;
    private Player parent;
    private vec3 force;

    this(Player parent)  {
        this.parent = parent;
        this.pushCount = flim(0.0, 0.0, 1);
        this.force = vec3(0);
        auto geom = Sphere.create(ElasticSphere.DEFAULT_RADIUS, ElasticSphere.RECURSION_LEVEL);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.entity = new Player.PlayerEntity(geom, mat, new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.particleList = entity.getMesh().geom.vertices.map!(p => new ElasticParticle(p.position)).array;
        //隣を発見
        uint[2][] pairIndex;
        uint[2] makePair(uint a,uint b) {
            return a < b ? [a,b] : [b,a];
        }
        foreach (face; geom.faces) {
            auto idx0 = face.indexList[0];
            auto idx1 = face.indexList[1];
            auto idx2 = face.indexList[2];

            if (pairIndex.canFind(makePair(idx0,idx1)) == false) {
                pairIndex ~= makePair(idx0,idx1);
                this.pairList ~= new ElasticPair(
                        particleList[idx0],
                        particleList[idx1]);
            }
            if (pairIndex.canFind(makePair(idx1,idx2)) == false) {
                pairIndex ~= makePair(idx1,idx2);
                this.pairList ~= new ElasticPair(
                        particleList[idx1],
                        particleList[idx2]);
            }
            if (pairIndex.canFind(makePair(idx2,idx0)) == false) {
                pairIndex ~= makePair(idx2,idx0);
                this.pairList ~= new ElasticPair(
                        particleList[idx2],
                        particleList[idx0]);
            }
        }
    }

    override void move() {
        vec3 g = this.calcCenter();

        this.rotateParticles(g);
        this.entity.obj.pos = g;

        //拘束解消
        {
            //隣との距離を計算
            foreach (pair; this.pairList) {
                pair.init();
            }
            foreach (k; 0..ITERATION_COUNT){
                //隣との拘束
                foreach (pair; this.pairList) {
                    pair.solve();
                }
            }
        }
        float baloonForce = this.calcBaloonForce();
        foreach (ref particle; this.particleList) {
            particle.force += particle.normal * baloonForce;
            particle.force.y -= GRAVITY * MASS;
            particle.velocity += particle.force * FORCE_COEF;
            move(particle);
            collision(particle);
            end(particle);
        }
        this.force.y = 0;
        if (this.force.length > 0) this.force = normalize(this.force) * SIDE_PUSH_FORCE;
        foreach (p; this.particleList) {
            p.force = this.force;
        }
        this.force = vec3(0);

        updateGeometry();
    }

    override void onDownPress() {
        this.pushCount += 0.1;
        vec3 g = this.calcCenter();
        auto lower = this.calcLower();
        auto upper = this.calcUpper();
        foreach (p; this.particleList) {
            //下向きの力
            auto len = (p.position - g).xz.length;
            auto t = (p.position.y - lower) / (upper - lower);
            float power = DOWN_PUSH_FORCE / pow(len + 0.6, 2.5);
            power = min(DOWN_PUSH_FORE_MIN, power);
            power *= t;
            p.force.y -= power * this.pushCount;
        }
    }
    override void onDownJustRelease() {
        this.pushCount = 0;
    }
    override void onLeftPress() {
        this.force -= this.parent.camera.rot.column[0].xyz;
    }
    override void onRightPress() {
        this.force += this.parent.camera.rot.column[0].xyz;
    }
    override void onForwardPress() {
        this.force -= this.parent.camera.rot.column[2].xyz;
    }
    override void onBackPress() {
        this.force += this.parent.camera.rot.column[2].xyz;
    }

    override void onNeedlePress() {}
    override void onNeedleRelease(){}

    override Player.PlayerEntity getEntity() {
        return entity;
    }

    override void leave() {
        parent.world.remove(entity);
    }

    void fromNeedle(NeedleSphere needleSphere) {
        foreach (particle; this.particleList) {
            particle.velocity = needleSphere.calcVelocity(particle.position);
        }
        parent.world.add(entity);
    }

    private void rotateParticles(vec3 center) {
        //移動量から強引に回転させる
        auto radius = this.calcRadius();
        auto dif = center - this.entity.obj.pos;
        dif.y = 0;
        auto axis = vec3(0,1,0).cross(dif);
        float len = axis.length;
        if (len > 0) {
            axis /= len;
            float angle = dif.length / radius;
            quat rot = quat.axisAngle(axis, angle);
            foreach (p; this.particleList) {
                p.position = rotate(p.position-center, rot) + center;
                p.normal = rotate(p.normal, rot);
            }
        }
    }

    private float calcVolume() {
        float volume = 0;
        auto center = this.entity.obj.pos;
        foreach (face; this.entity.getMesh().geom.faces) {
            auto a = this.particleList[face.indexList[0]].position - center;
            auto b = this.particleList[face.indexList[1]].position - center;
            auto c = this.particleList[face.indexList[2]].position - center;
            volume += mat3.determinant(mat3(a,b,c));
        }
        return abs(volume) / 6;
    }

    private float calcArea() {
        float area = 0;
        foreach (face; this.entity.getMesh().geom.faces) {
            auto a = this.particleList[face.indexList[0]].position;
            auto b = this.particleList[face.indexList[1]].position;
            auto c = this.particleList[face.indexList[2]].position;
            area += length(cross(a - b, a - c));
        }
        return area / 2;
    }

    private vec3 calcCenter() {
        return this.particleList.map!(p => p.position).sum / this.particleList.length;
    }

    private float calcRadius() {
        auto center = this.calcCenter();
        return this.particleList.map!(a => (a.position - center).length).sum / this.particleList.length;
    }

    private vec3 calcVelocity() {
        return this.particleList.map!(a => a.velocity).sum / this.particleList.length;
    }

    float calcLower() {
        return this.particleList.map!(p => p.position.y).reduce!min;
    }

    float calcUpper() {
        return this.particleList.map!(p => p.position.y).reduce!max;
    }

    private float calcBaloonForce() {
        auto area = this.calcArea();
        auto volume = this.calcVolume();
        return BALOON_COEF * area / (volume * this.particleList.length);
    }

    private void move(ElasticParticle particle) {
        particle.position += particle.velocity * Player.TIME_STEP;
        particle.isGround = false;
    }

    private void collision(ElasticParticle particle) {
        auto colInfos = Array!CollisionInfo(0);
        this.parent.floors.collide(colInfos, particle.entity);
        scope (exit) {
            colInfos.destroy();
        }
        foreach (colInfo; colInfos) {
            if (!colInfo.collided) continue;
            auto floor = cast(CollisionPolygon)colInfo.colEntry.getGeometry();
            if (floor is null) floor = cast(CollisionPolygon)colInfo.colEntry2.getGeometry();
            float depth = -(particle.position - floor.positions[0]).dot(floor.normal);
            if (depth < 0) continue;
            auto po = particle.velocity - dot(particle.velocity, floor.normal) * floor.normal;
            particle.velocity -= po * FRICTION;
            particle.isGround = true;
            if (dot(particle.velocity, floor.normal) < 0) {
                particle.velocity -= floor.normal * dot(floor.normal, particle.velocity) * 1;
            }
            particle.position += floor.normal * depth;
        }
    }

    private void end(ElasticParticle particle) {
        particle.force = vec3(0,0,0); //用済み
        particle.capsule.setEnd(particle.capsule.start);
        particle.capsule.setStart(particle.position);
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

    class ElasticParticle {
        vec3 position; /* in World, used for Render */
        vec3 velocity;
        vec3 normal; /* in World */
        vec3 force;
        bool isGround;
        bool isStinger;
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

        void move() {
           this.force = vec3(0,0,0); //用済み
           this.capsule.setEnd(this.capsule.start);
           this.capsule.setStart(this.position);
        }
    }

    class ElasticPair {
        private ElasticParticle p0, p1;
        private vec3 dist;
        private vec3 force;
        private float deflen;

        this(ElasticParticle p0, ElasticParticle p1) {
            this.p0 = p0;
            this.p1 = p1;
            this.deflen = length(this.p1.position - this.p0.position);
        }

        void init() {
            vec3 d = this.p1.position - this.p0.position;
            auto len = d.length;
            if (len > 0) d /= len;
            len -= deflen;
            d *= len;
            this.dist = d;
        }

        void solve() {
            vec3 v1 = this.p1.velocity - this.p0.velocity;
            vec3 v2 = v1 * VEL_COEF + this.dist * POS_COEF;
            vec3 dv = (v2 - v1) * 0.5f;
            this.p0.velocity -= dv;
            this.p1.velocity += dv;
        }
    }
}
