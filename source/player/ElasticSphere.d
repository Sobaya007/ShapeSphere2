module player.ElasticSphere;

import player.PlayerMaterial;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class ElasticSphere {


    immutable {
        uint RECURSION_LEVEL = 2;
        float DEFAULT_RADIUS = 0.5;
        float MASS = 0.05;
        float TIME_STEP = 0.02;
        float ZETA = 0.5;
        float OMEGA = 100;
        float c = 2 * ZETA * OMEGA * MASS;
        float k = MASS * OMEGA * OMEGA;
        float FRICTION = 0.3;
        float GRAVITY = 100;
        uint ITERATION_COUNT = 20;

        float VEL_COEF = 1 / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float POS_COEF = - (TIME_STEP*k/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float FORCE_COEF = (TIME_STEP/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float BALOON_COEF = 20000;
    }

    Pair[] pairList;

    CollisionMesh[] floors;
    Mesh mesh;
    GeometryN geom;
    Particle[] particleList;
    float radius;
    float deflen;
    float lowerY, upperY;
    vec3 lVel, aVel;
    flim needleCount;

    vec3 collisionNormal;
    ubool condition;
    CollisionMesh colMesh;
    CollisionCapsule capsule;

    this()  {
        this.radius = DEFAULT_RADIUS;
        this.geom = Sphere.create(this.radius, RECURSION_LEVEL);
        foreach (v; geom.vertices) {
            this.particleList ~= new Particle(v.position);
        }
        this.particleList.each!( p => p.p += vec3(0,20,0));

        uint[2] makePair(uint a, uint b) {
            return a < b ? [a,b] : [b,a];
        }
        //隣を発見
        uint[2][] pairIndex;
        foreach (face; geom.faces) {
            auto idx0 = face.indexList[0];
            auto idx1 = face.indexList[1];
            auto idx2 = face.indexList[2];

            if (pairIndex.canFind(makePair(idx0,idx1)) == false) pairIndex ~= makePair(idx0,idx1);
            if (pairIndex.canFind(makePair(idx1,idx2)) == false) pairIndex ~= makePair(idx1,idx2);
            if (pairIndex.canFind(makePair(idx2,idx0)) == false) pairIndex ~= makePair(idx2,idx0);
        }
        foreach (i; pairIndex) {
            this.particleList[i[0]].next ~= particleList[i[1]];
            this.particleList[i[1]].next ~= particleList[i[0]];
            this.pairList ~= new Pair(this.particleList[i[0]], this.particleList[i[1]]);
        }
        foreach(p; this.particleList) {
            p.isStinger = p.next.all!(a => a.isStinger == false);
        }

        this.needleCount = flim(0,0,1);
        auto mat = new ConditionalMaterial!(PlayerMaterial, LambertMaterial);
        mat.ambient = vec3(1);
        this.condition = mat.condition;
        this.mesh = new Mesh(geom, mat);
        this.deflen = 0;
        foreach (pair; this.pairList) {
            this.deflen += length(pair.p0.p - pair.p1.p);
        }
        this.deflen /= this.pairList.length;

        this.capsule = new CollisionCapsule(0.1, this.mesh.obj.pos, this.mesh.obj.pos);
        this.colMesh = new CollisionMesh(this.capsule);
    }

    void move() {
        //体積の測定
        float volume = this.calcVolume();
        //表面積の測定
        float area = this.calcArea();
        //重心を求める
        vec3 g = this.particleList.map!(a => a.p).sum / this.particleList.length;
        //半径を求める
        this.radius = this.particleList.map!(a => (a.p - g).length).sum / this.particleList.length;
        //速度を求める
        lVel = this.particleList.map!(a => a.v).sum / this.particleList.length;
        aVel = vec3(0);
        this.lowerY = this.particleList.map!(p => p.p.y).reduce!min;
        this.upperY = this.particleList.map!(p => p.p.y).reduce!max;

        //移動量から強引に回転させる
        {
            vec3 dif = g - this.mesh.obj.pos;
            dif.y = 0;
            vec3 axis = vec3(0,1,0).cross(dif);
            float len = axis.length;
            if (len > 0) {
                axis /= len;
                float angle = dif.length / this.radius;
                quat rot = quat.axisAngle(axis, angle);
                foreach (p;particleList) {
                    p.p = rotate(p.p-g, rot) + g;
                    p.n = rotate(p.n, rot);
                }
            }
        }
        this.mesh.obj.pos = g;

        //†ちょっと†ふくらませる
        {
            import std.stdio;
            float force = BALOON_COEF * area / (volume * particleList.length);
            foreach (ref particle; this.particleList) {
                particle.force += particle.n * force;
            }
        }
        //重力
        foreach (p; this.particleList) {
            p.force.y -= GRAVITY * MASS;
        }
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
        foreach (ref particle; this.particleList) {
            particle.v += (particle.force + particle.extForce) * FORCE_COEF;
        }

        foreach (ref particle; this.particleList) {
            particle.move();
        }
        foreach (i, ref p; this.particleList) {
            this.geom.vertices[i].normal = vec3(0);
        }
        import std.stdio;
        foreach (face; this.geom.faces) {
            auto normal = normalize(cross(
                    this.geom.vertices[face.indexList[2]].position - this.geom.vertices[face.indexList[0]].position,
                    this.geom.vertices[face.indexList[1]].position - this.geom.vertices[face.indexList[0]].position));
            this.geom.vertices[face.indexList[0]].normal += normal;
            this.geom.vertices[face.indexList[1]].normal += normal;
            this.geom.vertices[face.indexList[2]].normal += normal;
        }
        foreach (i,v; this.geom.vertices) {
            auto p = this.particleList[i];
            v.normal = safeNormalize(v.normal);
            v.position = (this.mesh.obj.viewMatrix * vec4(p.p - v.normal * needle(p.isStinger), 1)).xyz;
        }
        this.geom.updateBuffer();

        this.capsule.end = this.capsule.start;
        this.capsule.start = this.mesh.obj.pos;
        this.capsule.start.y = 0;
    }

    private float needle(bool isNeedle){
        float t = needleCount;
        float arrival = isNeedle ? 2 : 1;
        return -t + t * arrival;
    }

    private float calcVolume() {
        float volume = 0;
        auto center = mesh.obj.pos;
        foreach (face; this.geom.faces) {
            auto a = particleList[face.indexList[0]].p - center;
            auto b = particleList[face.indexList[1]].p - center;
            auto c = particleList[face.indexList[2]].p - center;
            volume += mat3.determinant(mat3(a,b,c));
        }
        return abs(volume) / 6;
    }

    private float calcArea() {
        float area = 0;
        foreach (face; this.geom.faces) {
            auto a = particleList[face.indexList[0]].p;
            auto b = particleList[face.indexList[1]].p;
            auto c = particleList[face.indexList[2]].p;
            area += length(cross(a - b, a - c));
        }
        return area / 2;
    }


    class Particle {
        vec3 p;
        vec3 v;
        vec3 n;
        vec3 force;
        vec3 extForce;
        bool isGround;
        bool isStinger;
        Particle[] next;
        CollisionMesh colMesh;
        CollisionCapsule capsule;

        this(vec3 p) {
            this.p = p;
            this.n = normalize(p);
            this.v = vec3(0,0,0);
            this.force = vec3(0,0,0);
            this.extForce = vec3(0,0,0);
            this.capsule = new CollisionCapsule(0.1, this.p, this.p);
            this.colMesh = new CollisionMesh(this.capsule);
        }

        void move() {

            p += v * TIME_STEP;

            isGround = false;

            foreach (f; floors) {
                if (!f.collide(this.colMesh).collided) {
                    continue;
                }
                auto floor = f.geom.peek!CollisionPolygon;
                float depth = -(p + n * needle(isStinger) - floor.positions[0]).dot(floor.normal);
                if (depth > 0) {
                    p += floor.normal * depth;
                    auto po = v - dot(v, floor.normal) * floor.normal;
                    v -= po * FRICTION;
                    isGround = true;
                    if (dot(v, floor.normal) < 0) {
                        v -= floor.normal * dot(floor.normal, v) * 1.2;
                    }
                }
            }
            force = vec3(0,0,0); //用済み
            this.capsule.end = this.capsule.start;
            this.capsule.start = p + n * needle(isStinger);
        }
    }

    class Pair {
        Particle p0, p1;
        vec3 dist;
        vec3 force;

        this(Particle p0, Particle p1) {
            this.p0 = p0;
            this.p1 = p1;
        }

        void init() {
            vec3 d = this.p1.p - this.p0.p;
            auto len = d.length;
            if (len > 0) d /= len;
            len -= deflen;
            d *= len;
            this.dist = d;
            this.force = (this.p1.force + this.p0.force) / 2; //適当です
        }

        void solve() {
            vec3 v1 = this.p1.v - this.p0.v;
            vec3 v2 = v1 * VEL_COEF + this.dist * POS_COEF;
            vec3 dv = (v2 - v1) * 0.5f;
            this.p0.v -= dv;
            this.p1.v += dv;
        }
    }

}
