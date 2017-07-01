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
        float MASS = .1;
        float ZETA = 0.9;
        float OMEGA = 150;
        float c = 2 * ZETA * OMEGA * MASS;
        float k = MASS * OMEGA * OMEGA;
        float h = 0.02;
        float FRICTION = 100;
        float GRAVITY = .5;
        uint ITERATION_COUNT = 50;

        float ERP = h * k / c;
        float CFM = 1 / c;

        float POS_COEF = -ERP / (h * (CFM + 1 / MASS));
        float VEL_COEF = -1 / (CFM + 1 / MASS);
        float FORCE_COEF = -CFM / (CFM + h / MASS);
        float BALOON_COEF = 300;
    }

    Pair[] pairList;
    Collision[] collisionList;
    vec3[] floorSinkList;

    CollisionMesh[] floors;
    Mesh mesh;
    GeometryN geom;
    Particle[] particleList;
    float radius;
    float lowerY, upperY;
    vec3 lVel, aVel;
    flim needleCount;

    vec3 collisionNormal;
    ubool condition;
    TimeLogger logger;

    this()  {
        this.radius = DEFAULT_RADIUS;
        this.geom = Sphere.create(this.radius, RECURSION_LEVEL);
        foreach (v; geom.vertices) {
            this.particleList ~= new Particle(v.position);
        }

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
        this.floorSinkList = new vec3[geom.vertices.length];
        auto mat = new ConditionalMaterial!(PlayerMaterial, LambertMaterial);
        mat.ambient = vec3(1);
        this.condition = mat.condition;
        this.mesh = new Mesh(geom, mat);
        this.logger = new TimeLogger("Elastic logger");
    }

    void move() {
        logger.start("1");
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
                    //p.p = rotate(p.p-g, rot) + g;
                    p.n = rotate(p.n, rot);
                }
            }
        }
        this.mesh.obj.pos = g;

        //†ちょっと†ふくらませる
        {
            float force = BALOON_COEF * area / (volume * particleList.length);
            foreach (ref particle; this.particleList) {
                particle.force += normalize(particle.p - g) * force;
            }
        }
        //重力
        foreach (p; this.particleList) {
            p.force.y -= GRAVITY * MASS;
        }
        foreach (ref particle; this.particleList) {
            particle.v += (particle.force + particle.extForce) / MASS;
        }
        logger.stop();
        logger.start("2");

        this.collisionList = null;
        foreach (floor; this.floors) {
            foreach (particle; this.particleList) {
                if (!floor.collide(particle.colMesh).collided) continue;
                this.collisionList ~= new Collision(particle, *floor.geom.peek!CollisionPolygon);
            }
        }
        //拘束解消
        {
            //隣との距離を計算
            foreach (pair; this.pairList) {
                pair.init();
            }
            //床とのめり込みを計算
            foreach (i, p; particleList) {
                floorSinkList[i] = vec3(0, -min(0, p.p.y), 0);
            }
            logger.stop();
            logger.start("2.5");
            foreach (k; 0..ITERATION_COUNT){
                //隣との拘束
                foreach (pair; this.pairList) {
                    pair.solve();
                }
                //床の拘束
                foreach (col; this.collisionList) {
                    col.solve();
                }
            }
        }
        logger.stop();
        logger.start("3");

        foreach (ref particle; this.particleList) {
            particle.move();
        }
        foreach (i, ref p; this.particleList) {
            this.geom.vertices[i].normal = vec3(0);
        }
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
        logger.stop();
        logger.start("4");
        this.geom.updateBuffer();
        logger.stop();
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
        return volume / 6;
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

    class Collision {
        Particle particle;
        CollisionPolygon polygon;
        float targetVel;
        vec3 nor, tan, bin;
        float normalTotalImpulse;
        float tangentTotalImpulse;
        float binTotalImpulse;

        this(Particle particle, CollisionPolygon polygon) {
            this.particle = particle;
            this.polygon = polygon;
            this.nor = this.polygon.normal;
            import std.random;
            vec3 po;
            do {
                po = vec3(uniform(0, 1.0), uniform(0, 1.0), uniform(0, 1.0));
            } while(abs(dot(po, this.nor)) == 1.0);
            this.tan = normalize(po - dot(po, this.nor) * this.nor);
            this.bin = cross(this.nor, this.tan);
            this.targetVel = 0;
            this.normalTotalImpulse = 0;
            this.tangentTotalImpulse = 0;
            this.binTotalImpulse = 0;
        }

        void solve() {
            // normal
            float oldImpulse = this.normalTotalImpulse;
            float newImpulse = (targetVel - this.particle.v.dot(this.nor));
            this.normalTotalImpulse += newImpulse;
            if (this.normalTotalImpulse < 0) this.normalTotalImpulse = 0;
            newImpulse = this.normalTotalImpulse - oldImpulse;
            particle.v += newImpulse * this.nor;

            //tan
            float oldTanImpulse = this.tangentTotalImpulse;
            float newTanImpulse = -this.particle.v.dot(this.tan);
            this.tangentTotalImpulse += newTanImpulse;
            if (abs(this.tangentTotalImpulse) > this.normalTotalImpulse * FRICTION)
                this.tangentTotalImpulse = this.normalTotalImpulse * FRICTION * sgn(this.tangentTotalImpulse);
            newTanImpulse = this.tangentTotalImpulse - oldTanImpulse;
            particle.v += newTanImpulse * this.tan;

            //bin
            float oldBinImpulse = this.binTotalImpulse;
            float newBinImpulse = -this.particle.v.dot(this.bin);
            this.binTotalImpulse += newBinImpulse;
            if (abs(this.binTotalImpulse) > this.normalTotalImpulse * FRICTION)
                this.binTotalImpulse = this.normalTotalImpulse * FRICTION * sgn(this.tangentTotalImpulse);
            newBinImpulse = this.binTotalImpulse - oldBinImpulse;
            particle.v += newBinImpulse * this.bin;
        }
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
            this.p.y += 20;
            this.capsule = new CollisionCapsule(0.1, this.p, this.p);
            this.colMesh = new CollisionMesh(this.capsule);
        }

        void move() {
            p += v * h;
            force = vec3(0,0,0); //用済み

            this.capsule.end = this.capsule.start;
            this.capsule.start = p;
        }
    }

    class Pair {
        Particle p0, p1;
        const float deflen;
        float dist;
        vec3 force;
        vec3 n;

        this(Particle p0, Particle p1) {
            this.p0 = p0;
            this.p1 = p1;
            this.deflen = length(p0.p - p1.p) * 10;
        }

        void init() {
            this.n = this.p1.p - this.p0.p;
            this.dist = length(this.n);
            if (this.dist > 0) this.n /= this.dist;
            this.force = vec3(0);
        }

        void solve() {
            auto v1 = this.p1.v - this.p0.v;
            auto dlambda = POS_COEF * this.dist * this.n + VEL_COEF * v1 + FORCE_COEF * this.force;
            this.force += dlambda;
            vec3 dv = dlambda / MASS;
            this.p0.v -= dv / 2;
            this.p1.v += dv / 2;
        }
    }
}
