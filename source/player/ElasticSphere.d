module player.ElasticSphere;

import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class ElasticSphere {


    immutable {
        uint RECURSION_LEVEL = 2;
        float DEFAULT_RADIUS = 0.5;
        float MASS = 0.1;
        float TIME_STEP = 0.02;
        float ZETA = 0.5;
        float OMEGA = 100;
        float c = 2 * ZETA * OMEGA * MASS;
        float k = MASS * OMEGA * OMEGA;
        float FRICTION = 0.3;
        float GRAVITY = 180;

        float VEL_COEF = 1 / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float POS_COEF = - (TIME_STEP*k/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float FORCE_COEF = (TIME_STEP/MASS) / (1+TIME_STEP*c/MASS+TIME_STEP*TIME_STEP*k/MASS);
        float BALOON_COEF = 1;
    }

    uint[][] pairIndex;
    vec3[] dList;
    vec3[] forceList;
    vec3[] floorSinkList;

    CollisionPolygon[] floors;
    Mesh mesh;
    GeometryN geom;
    Particle[] particleList;
    float radius;
    float deflen;
    vec3 lVel, aVel;
    flim needleCount;

    vec3 collisionNormal;

    this()  {
        this.radius = DEFAULT_RADIUS;
        this.deflen = this.radius * 2 * (1 - 1 / sqrt(5.0f)) / (RECURSION_LEVEL + 1);
        this.geom = Sphere.create(this.radius, RECURSION_LEVEL);
        foreach (v; geom.vertices) {
            this.particleList ~= new Particle(v.position);
        }
        //foreach(p; this.particleList) {
        //    bool ok = true;
        //    foreach (n; p.next) if (n.isStinger) ok = false;
        //    if (ok) p.isStinger = true;
        //}
        this.particleList.each!( p => p.p += vec3(0,0,0));

        uint[] makePair(uint a, uint b) {
            return a < b ? [a,b] : [b,a];
        }
        //隣を発見
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
        }

        this.needleCount = flim(0,0,1);
        this.dList = new vec3[pairIndex.length];
        this.forceList = new vec3[pairIndex.length];
        this.floorSinkList = new vec3[geom.vertices.length];
        this.mesh = new Mesh(geom, new NormalMaterial());
        this.floors = [new CollisionPolygon([vec3(-1,0,-1), vec3(0,0,+1), vec3(+1, 0, -1)])];
    }

    void draw() {
//
//        foreach (i, ref p;particleList) {
//            if (p.isStinger)
//                vertexArray[i*3..i*3+3] = (p.p + p.n * needle).array;
//            else
//                vertexArray[i*3..i*3+3] = (p.p - p.n * needle * .3).array;
//        }
//
//        // Recalculate the normal for Graphics
//        foreach (ref n;normalSum) n = vec3(0,0,0);
//        foreach (face; this.geom.faces) {
//            int i0 = face.indexList[0];
//            int i1 = face.indexList[1];
//            int i2 = face.indexList[2];
//            vec3 v01 = particleList[i1].p - particleList[i0].p;
//            vec3 v02 = particleList[i2].p - particleList[i0].p;
//            vec3 n = normalize(cross(v01, v02));
//            normalSum[i0] += n;
//            normalSum[i1] += n;
//            normalSum[i2] += n;
//            normalCount[i0]++;
//            normalCount[i1]++;
//            normalCount[i2]++;
//        }
//        for(int i=0;i<particleList.length;i++){
//            if(normalCount[i] > 0)normalSum[i] /= normalCount[i];
//            normalArray[i*3..(i+1)*3] = normalize(normalSum[i]).array;
//        }
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

        writeln("volume = ", volume);
        writeln("area = ", area);
        writeln("radius = ", radius);
        writeln("g = ", g);

        //移動量から強引に回転させる
        //{
        //    vec3 dif = g - this.mesh.obj.pos;
        //    dif.y = 0;
        //    vec3 axis = vec3(0,1,0).cross(dif);
        //    float len = axis.length;
        //    if (len > 0) {
        //        axis /= len;
        //        float angle = dif.length / this.radius;
        //        quat rot = quat.axisAngle(axis, angle);
        //        foreach (p;particleList) {
        //            p.p = rotate(p.p-g, rot) + g;
        //            p.n = rotate(p.n, rot);
        //        }
        //    }
        //}
        this.mesh.obj.pos = g;

        //†ちょっと†ふくらませる
        {
            float force = BALOON_COEF * area / (volume * particleList.length);
            writeln("force = ", force);
            foreach (ref particle; this.particleList) {
                particle.force += particle.n * force;
            }
        }
        //重力
        foreach (p; this.particleList) {
            //p.force.y -= GRAVITY * MASS;
        }
        //拘束解消
        {
            //隣との距離を計算
            foreach (i; 0..pairIndex.length) {
                vec3 d = particleList[pairIndex[i][1]].p - particleList[pairIndex[i][0]].p;	
                auto len = d.length;
                if (len > 0) d /= len;
                len -= deflen;
                d *= len;
                dList[i] = d;
                forceList[i] = (particleList[pairIndex[i][1]].force + particleList[pairIndex[i][0]].force) / 2; //適当です
            }
            //床とのめり込みを計算
            foreach (i, p; particleList) {
                floorSinkList[i] = vec3(0, -min(0, p.p.y), 0);
            }
            foreach (k; 0..20){
                //隣との拘束
                foreach (i; 0..pairIndex.length) {
                    auto id0 = pairIndex[i][0], id1 = pairIndex[i][1];
                    vec3 v1 = particleList[id1].v - particleList[id0].v;
                    vec3 v2 = v1 * VEL_COEF + dList[i] * POS_COEF;
                    vec3 dv = (v2 - v1) * 0.5f;
                    particleList[id0].v -= dv;
                    particleList[id1].v += dv;
                }
            }
        }
        //なんかうまくいかないので定数だけ分離
        foreach (ref particle; this.particleList) {
            particle.v += (particle.force + particle.extForce) * FORCE_COEF;
        }

        foreach (ref particle; this.particleList) {
            particle.move();
        }
        foreach (i, ref p; this.particleList) {
            this.geom.vertices[i].position = p.p;
        }
        this.geom.updateBuffer();
    }

    private float needle(){
        return ( -pow( 2, -5 * needleCount ) + 1 );
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


    class Particle {
        vec3 p;
        vec3 v;
        vec3 n;
        vec3 force;
        vec3 extForce;
        bool isGround;
        bool isStinger;
        Particle[] next;

        this(vec3 p) {
            this.p = p;
            this.n = normalize(p);
            this.v = vec3(0,0,0);
            this.force = vec3(0,0,0);
            this.extForce = vec3(0,0,0);
        }

        void move() {

            p += v * TIME_STEP;

            isGround = false;

            foreach (f; floors) {
                float depth = -(p - f.positions[0]).dot(f.normal) + radius + needleCount;
                vec4 foot = mat4.invert(f.obj.viewMatrix) * vec4(p, 1);
                if (foot.x < -1) continue;
                if (foot.x > 1) continue;
                if (foot.z < -1) continue;
                if (foot.z > 1) continue;
                if (depth > radius) {
                    //v.y = (depth - radius) / TIME_STEP;
                    //v.x *= 1 - FRICTION;
                    //v.z *= 1 - FRICTION;
                    isGround = true;
                }
            }
            force = vec3(0,0,0); //用済み
        }
    }

}
