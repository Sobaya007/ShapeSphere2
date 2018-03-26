module game.player.ElasticSphere2;

import game.stage.Map;
import game.Game;
import game.player.Player;
import game.player.PlayerMaterial;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;
import std.typecons;

class ElasticSphere2 {

    private static immutable {
        uint RECURSION_LEVEL = 2;
        float DEFAULT_RADIUS = 0.5;
        float RADIUS = 2.0f;
    }

    private {
        mixin DeclareConfig!(float, "FRICTION", "elastic.json");
        mixin DeclareConfig!(float, "GRAVITY", "elastic.json");
        mixin DeclareConfig!(float, "BALOON_COEF", "elastic.json");
        mixin DeclareConfig!(float, "MAX_VELOCITY", "elastic.json");
        mixin DeclareConfig!(uint, "ITERATION_COUNT", "elastic.json");
        mixin DeclareConfig!(ChangeObserved!(ConfigValue!float), float, "TIME_STEP", "elastic.json"); 
        mixin DeclareConfig!(ChangeObserved!(ConfigValue!float), float, "ZETA", "elastic.json"); 
        mixin DeclareConfig!(ChangeObserved!(ConfigValue!float), float, "OMEGA", "elastic.json"); 
        mixin DeclareConfig!(ChangeObserved!(ConfigValue!float), float, "MASS", "elastic.json"); 
        Depends!((float ZETA, float OMEGA, float MASS) => 2 * ZETA * OMEGA * MASS) C;
        Depends!((float OMEGA, float MASS) => OMEGA * OMEGA* MASS) K;
        Depends!((float TIME_STEP, float MASS, float C, float K) => 1 / (1 + TIME_STEP*C/MASS + TIME_STEP*TIME_STEP*K/MASS)) VEL_COEF;
        Depends!((float TIME_STEP, float MASS, float C, float K) => - (TIME_STEP*K/MASS) / (1 + TIME_STEP*C/MASS + TIME_STEP*TIME_STEP*K/MASS)) POS_COEF;
        Depends!((float TIME_STEP, float MASS, float C, float K) => (TIME_STEP/MASS) / (1 + TIME_STEP*C/MASS + TIME_STEP*TIME_STEP*K/MASS)) FORCE_COEF;
    }

    private ElasticParticle[] particleList;
    private ElasticPair[] pairList;
    private GeometrySphere geom;
    Entity entity;
    private CollisionCapsule capsule;
    vec3 force;
    private Depends!((const vec3[] positions) => sum(positions) / positions.length) center;
    private Depends!((const vec3[] vels) => sum(vels) / vels.length) lVel;
    private Depends!((const vec3 center, const vec3 lVel, const vec3[] positions, const vec3[] vels) {
        return sum(zip(positions, vels).map!((t) {
            auto r = t[0] - center;
            auto v = t[1] - lVel;
            return cross(r, v) / lengthSq(r);
        })) / positions.length;
    }) aVel;
    private ChangeObservedArray!vec3 positions, velocities;
    Maybe!vec3 contactNormal;

    debug size_t collisionCount;

    this() {
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        mat.config.faceMode = FaceMode.Front;
        mat.config.renderGroupName = "transparent";
        this(mat);
    }

    this(Material mat) {
        C.depends(ZETA, OMEGA, MASS);
        K.depends(OMEGA, MASS);
        VEL_COEF.depends(TIME_STEP, MASS, C, K);
        POS_COEF.depends(TIME_STEP, MASS, C, K);
        FORCE_COEF.depends(TIME_STEP, MASS, C, K);
        this.force = vec3(0);
        this.geom = Sphere.create(DEFAULT_RADIUS, RECURSION_LEVEL);
        this.entity = new Entity(geom, mat, this.capsule = new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.entity.name = "ElasticSphere";
        this.particleList = geom.vertices.map!(p => new ElasticParticle(p.position)).array;
        auto p = this.particleList.map!(p => &p.position).array;
        auto v = this.particleList.map!(p => &p.velocity).array;
        this.positions = ChangeObservedArray!vec3(p);
        this.velocities = ChangeObservedArray!vec3(v);
        this.center.depends(positions);
        this.lVel.depends(velocities);
        this.aVel.depends(this.center, this.lVel, positions, velocities);
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
        foreach(pair; this.pairList) {
            pair.p0.next ~= pair.p1;
            pair.p1.next ~= pair.p0;
        }
    }

    void setCenter(vec3 center) {
        auto d = center - this.getCenter;
        foreach (particle; this.particleList) {
            particle.position += d;
        }
    }

    vec3 getCenter() {
        return this.center;
    }

    vec3 getLinearVelocity() {
        return this.lVel;
    }

    vec3 getAngularVelocity() {
        return this.aVel;
    }

    // pos, dir, error
    struct WallContact {
        vec3 pos;
        vec3 dir;

        this(vec3 pos, vec3 dir) { this.pos = pos; this.dir = dir;}
    }

    Maybe!WallContact getWallContact() {
        auto colInfos = Array!CollisionInfo(0);
        Game.getMap().getStageEntity().collide(colInfos, this.entity);
        scope (exit) {
            colInfos.destroy();
        }
        foreach (info; colInfos) {
            auto n = info.getPushVector(this.entity);
            auto nearestParticle = this.getNearestParticle(this.center - n * 114514);
            return Just(WallContact(nearestParticle.position, n));
        }
        return None!WallContact;
    }

    ElasticParticle[] getParticleList() {
        return this.particleList;
    }

    void move(Entity[] collisionEntities) {
        debug Game.startTimer("elastic solve");
        vec3 g = this.center;

        this.rotateParticles(g);
        this.entity.pos = g;


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
        this.contactNormal = None!vec3;

        auto entities = Array!Entity(0);
        scope(exit) entities.destroy();
        Game.getMap().getStageEntity().traverse((Entity e) {
            if (e.colEntry.isNone) return;
            auto info = Array!CollisionInfo(0);
            e.collide(info, this.entity);
            if (info.length > 0)
                entities ~= e;
        });
        debug collisionCount = entities.length;

        foreach (ref particle; this.particleList) {
            particle.force += particle.normal * baloonForce;
            if (this.contactNormal.isNone) particle.force.y -= GRAVITY * MASS;
            particle.velocity += particle.force * FORCE_COEF;
            move(particle);
            collision(particle, entities);
            end(particle);
        }
        this.force.y = 0;
        foreach (p; this.particleList) {
            p.force = this.force;
        }
        this.force = vec3(0);

        updateGeometry();
        debug Game.stopTimer("elastic solve");
    }

    void push(vec3 forceVector, float maxPower) {
        auto force = forceVector.length;
        auto n = forceVector / force;
        vec3 g = this.getCenter;
        auto minv = this.calcMin(-n);
        auto maxv = this.calcMax(-n);
        foreach (p; this.particleList) {
            //下向きの力
            auto v = p.position - g;
            v -= dot(v, n) * n;
            auto len = v.length;
            auto t = (p.position.dot(-n) - minv) / (maxv - minv);
            float power = force / pow(len + 0.6, 2.5);
            power = min(maxPower, power);
            power *= t;
            p.force += power * n;
        }
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
            auto angle = rad(dif.length / radius);
            quat rot = quat.axisAngle(axis, angle);
            foreach (p; this.particleList) {
                p.position = rotate(p.position-center, rot) + center;
                p.normal = rotate(p.normal, rot);
            }
        }
    }

    private float calcVolume() {
        float volume = 0;
        vec3 center = this.entity.obj.pos;
        foreach (face; geom.faces) {
            auto a = this.particleList[face.indexList[0]].position - center;
            auto b = this.particleList[face.indexList[1]].position - center;
            auto c = this.particleList[face.indexList[2]].position - center;
            volume += mat3.determinant(mat3(a,b,c));
        }
        return abs(volume) / 6;
    }

    private float calcArea() {
        float area = 0;
        foreach (face; geom.faces) {
            vec3 a = this.particleList[face.indexList[0]].position;
            vec3 b = this.particleList[face.indexList[1]].position;
            vec3 c = this.particleList[face.indexList[2]].position;
            area += length(cross(a - b, a - c));
        }
        return area / 2;
    }

    private float calcRadius() {
        float res = 0;
        foreach (p; this.particleList) {
            res += length(p.position - center);
        }
        return res / this.particleList.length;
    }

    private vec3 calcVelocity() {
        return this.particleList.map!(a => cast(vec3)a.velocity).sum / this.particleList.length;
    }

    float calcMin(vec3 n) {
        return this.particleList.map!(p => p.position.dot(n)).reduce!min;
    }

    float calcMax(vec3 n) {
        return this.particleList.map!(p => p.position.dot(n)).reduce!max;
    }

    private float calcBaloonForce() {
        auto area = this.calcArea();
        auto volume = this.calcVolume();
        return BALOON_COEF * area / (volume * this.particleList.length);
    }

    private void move(ElasticParticle particle) {
        if (particle.velocity.length > MAX_VELOCITY) {
            particle.velocity *= MAX_VELOCITY / particle.velocity.length;
        }
        particle.position += particle.velocity * Player.TIME_STEP;
        particle.capsule.setEnd(particle.capsule.start);
        particle.capsule.setStart(particle.position);
    }

    private void collision(ElasticParticle particle, ref Array!Entity entities) {
        auto colInfos = Array!CollisionInfo(0);
        scope(exit) colInfos.destroy();
        foreach (e; entities) {
            e.collide(colInfos, particle.entity);
        }
        foreach (colInfo; colInfos) {
            auto n = colInfo.getPushVector(particle.entity);
            auto depth = colInfo.getDepth();
            if (depth < 0) continue;
            auto po = particle.velocity - dot(particle.velocity, n) * n;
            particle.velocity -= po * FRICTION;
            if (this.contactNormal.isNone) this.contactNormal = Just(normalize(n));
            else this.contactNormal += normalize(n);
            if (dot(particle.velocity, n) < 0) {
                particle.velocity -= n * dot(n, particle.velocity) * 1;
            }
            particle.position += n * depth;
        }
        this.contactNormal = this.contactNormal.fmap!((vec3 n) => normalize(n));
    }

    private void end(ElasticParticle particle) {
        particle.force = vec3(0,0,0); //用済み
        particle.capsule.setEnd(particle.capsule.start);
        particle.capsule.setStart(particle.position);
    }

    private void updateGeometry() {
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
            v.position = (this.entity.viewMatrix * vec4(p.position.get, 1)).xyz;
        }
        debug Game.startTimer("elastic update");
        geom.updateBuffer();
        debug Game.stopTimer("elastic update");
    }

    //山登りで探索
    public ElasticParticle getNearestParticle(vec3 pos) {
        ElasticParticle particle = this.particleList[0];
        float minDist = length(particle.position - pos);
        while (true) {
            ElasticParticle newParticle = particle.next.minElement!(p => length(p.position - pos));
            float dist = length(newParticle.position - pos);
            if (dist < minDist) {
                minDist = dist;
            } else {
                return particle;
            }
            particle = newParticle;
        }
    }

    class ElasticParticle {
        ChangeObserved!vec3 position; /* in World, used for Render */
        ChangeObserved!vec3 velocity;
        vec3 normal; /* in World */
        vec3 force;
        bool isStinger;
        Entity entity;
        CollisionCapsule capsule;
        ElasticParticle[] next;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
            this.velocity = vec3(0);
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
