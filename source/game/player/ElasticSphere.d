module game.player.ElasticSphere;

import game.player.PlayerMaterial;
import game.player.Particle;
import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

class ElasticSphere {

    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        uint RECURSION_LEVEL = 2;
        float DEFAULT_RADIUS = 0.5;
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
    }

    private ElasticPair[] pairList;
    private Player parent;

    private vec3 lVel;
    flim needleCount;

    this(Player parent)  {
        this.parent = parent;
        this.needleCount = flim(0,0,1);
        foreach (pair; parent.pairList) {
            this.pairList ~= new ElasticPair(pair);
        }
    }

    void move() {
        this.step();
        this.updateGeometry();
    }

    private void step() {
        vec3 g = this.calcCenter();
        this.lVel = this.calcVelocity();

        this.rotateParticles(g);
        this.parent.entity.obj.pos = g;

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
        float force = this.calcBaloonForce();
        foreach (ref particle; this.parent.particleList) {
            particle.force += particle.normal * force;
            particle.force.y -= GRAVITY * MASS;
            particle.velocity += particle.force * FORCE_COEF;
            move(particle);
            collision(particle);
            end(particle);
        }
    }

    private void rotateParticles(vec3 center) {
        //移動量から強引に回転させる
        auto radius = this.calcRadius();
        auto dif = center - this.parent.entity.obj.pos;
        dif.y = 0;
        auto axis = vec3(0,1,0).cross(dif);
        float len = axis.length;
        if (len > 0) {
            axis /= len;
            float angle = dif.length / radius;
            quat rot = quat.axisAngle(axis, angle);
            foreach (p; this.parent.particleList) {
                p.position = rotate(p.position-center, rot) + center;
                p.normal = rotate(p.normal, rot);
            }
        }
    }

    private void updateGeometry() {
        auto vs = this.parent.entity.getMesh().geom.vertices;
        foreach (ref v; vs) {
            v.normal = vec3(0);
        }
        foreach (face; this.parent.entity.getMesh().geom.faces) {
            auto normal = normalize(cross(
                    vs[face.indexList[2]].position - vs[face.indexList[0]].position,
                    vs[face.indexList[1]].position - vs[face.indexList[0]].position));
            vs[face.indexList[0]].normal += normal;
            vs[face.indexList[1]].normal += normal;
            vs[face.indexList[2]].normal += normal;
        }
        foreach (i,v; vs) {
            auto p = this.parent.particleList[i];
            v.normal = safeNormalize(v.normal);
            v.position = (this.parent.entity.obj.viewMatrix * vec4(needlePosition(p), 1)).xyz;
        }
    }

    private float calcVolume() {
        float volume = 0;
        auto center = this.parent.entity.obj.pos;
        foreach (face; this.parent.entity.getMesh().geom.faces) {
            auto a = this.parent.particleList[face.indexList[0]].position - center;
            auto b = this.parent.particleList[face.indexList[1]].position - center;
            auto c = this.parent.particleList[face.indexList[2]].position - center;
            volume += mat3.determinant(mat3(a,b,c));
        }
        return abs(volume) / 6;
    }

    private float calcArea() {
        float area = 0;
        foreach (face; this.parent.entity.getMesh().geom.faces) {
            auto a = this.parent.particleList[face.indexList[0]].position;
            auto b = this.parent.particleList[face.indexList[1]].position;
            auto c = this.parent.particleList[face.indexList[2]].position;
            area += length(cross(a - b, a - c));
        }
        return area / 2;
    }

    private vec3 calcCenter() {
        return this.parent.particleList.map!(p => p.position).sum / this.parent.particleList.length;
    }

    private float calcRadius() {
        auto center = this.calcCenter();
        return this.parent.particleList.map!(a => (a.position - center).length).sum / this.parent.particleList.length;
    }

    private vec3 calcVelocity() {
        return this.parent.particleList.map!(a => a.velocity).sum / this.parent.particleList.length;
    }

    float calcLower() {
        return this.parent.particleList.map!(p => p.position.y).reduce!min;
    }

    float calcUpper() {
        return this.parent.particleList.map!(p => p.position.y).reduce!max;
    }

    private float  calcBaloonForce() {
        auto area = this.calcArea();
        auto volume = this.calcVolume();
        return BALOON_COEF * area / (volume * this.parent.particleList.length);
    }

    private void move(Particle particle) {
        particle.position += particle.velocity * Player.TIME_STEP;
        particle.isGround = false;
    }

    private void collision(Particle particle) {
        foreach (f; this.parent.floors) {
            auto colInfos = Array!CollisionInfo(0);
            f.collide(colInfos, particle.entity);
            auto collided = colInfos.all!(a => !a.collided);
            colInfos.destroy();
            if (collided) {
                continue;
            }
            auto floor = cast(CollisionPolygon)f.getCollisionEntry().getGeometry();
            float depth = -(this.needlePosition(particle) - floor.positions[0]).dot(floor.normal);
            if (depth > 0) {
                auto po = particle.velocity - dot(particle.velocity, floor.normal) * floor.normal;
                particle.velocity -= po * FRICTION;
                particle.isGround = true;
                if (dot(particle.velocity, floor.normal) < 0) {
                    particle.velocity -= floor.normal * dot(floor.normal, particle.velocity) * 1;
                }
                particle.position += floor.normal * depth;
            }
        }
    }

    private void end(Particle particle) {
        particle.force = vec3(0,0,0); //用済み
        particle.capsule.setEnd(particle.capsule.start);
        particle.capsule.setStart(this.needlePosition(particle));
    }

    private vec3 needlePosition(Particle particle) {
        return particle.position + particle.normal * needle(particle.isStinger);
    }

    private float needle(bool isNeedle){
        alias t = this.needleCount;
        float arrival = isNeedle ? 2 : 0.9;
        return -t + t * arrival;
    }

    class ElasticPair {
        import game.player.Pair;
        private Pair pair;
        private vec3 dist;
        private vec3 force;
        private float deflen;

        this(Pair pair) {
            this.pair = pair;
            this.deflen = length(this.pair.p1.position - this.pair.p0.position);
        }

        void init() {
            vec3 d = this.pair.p1.position - this.pair.p0.position;
            auto len = d.length;
            if (len > 0) d /= len;
            len -= deflen;
            d *= len;
            this.dist = d;
        }

        void solve() {
            vec3 v1 = this.pair.p1.velocity - this.pair.p0.velocity;
            vec3 v2 = v1 * VEL_COEF + this.dist * POS_COEF;
            vec3 dv = (v2 - v1) * 0.5f;
            this.pair.p0.velocity -= dv;
            this.pair.p1.velocity += dv;
        }
    }

}
