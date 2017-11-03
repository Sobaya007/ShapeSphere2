module game.player.SpringSphere;

public import game.player.BaseSphere;
public import game.player.ElasticSphere;
public import game.player.NeedleSphere;
import game.player.PlayerMaterial;
import game.player.PlayerChaseControl;
import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

private float TO_SPEED = 0.9;

private void to(ref float value, float arrival) {
    value = (value - arrival) * TO_SPEED + arrival;
}

class SpringSphere : BaseSphere {


    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        float GRAVITY = 20;
        float RADIUS = 2.0f;
        uint T_CUT = 20;
        uint P_CUT = 80;
        float PERIOD = 0.4;
        float DAMPING_RATIO = 0.3; //減衰比
        float MAX_LENGTH = 10;
        float MAX_SPIRAL = 5;
        float BASE_LENGTH = 5;
        float SHRINK_LENGTH = 1;
        float LARGE_RADIUS = 0.5;
        float SMALL_RADIUS = 0.1;
        float M = 1;
        float A = MAX_LENGTH - BASE_LENGTH; //振幅
        float K = M * (log(DAMPING_RATIO) ^^ 2 + (2*PI)^^2) / PERIOD^^2;
        float C = - 2 * log(DAMPING_RATIO) / PERIOD;
        float V0 = A / PERIOD * log(DAMPING_RATIO);
        float DELTA_TIME = 1.0f / 60.0f;

        float OMEGA0 = sqrt(K/M);
        float GAMMA = C/(2*M);

        static assert(GAMMA < OMEGA0); //減衰振動の条件
    }

    private SpringParticle[] particleList;
    private Player.PlayerEntity entity;
    private CollisionCapsule capsule;
    private ElasticSphere elasticSphere;
    private Camera camera;
    private Player parent;
    private PlayerChaseControl control;
    private Maybe!(ElasticSphere.WallContact) wallContact;
    private Spring spring;
    private GeometricInfo geom;
    private vec3 velocity;
    private Step stepImpl;
    private Step transform, wait, jump, fly, success, fail;
    private bool shouldFinish;

    this(Player parent, Camera camera, PlayerChaseControl control)  {
        this.parent = parent;
        this.camera = camera;
        this.control = control;
        this.spring = new Spring();
        auto geom = SphereUV.create!GeometryN(RADIUS, T_CUT, P_CUT);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.capsule = new CollisionCapsule(RADIUS, vec3(0), vec3(0));
        this.entity = new Player.PlayerEntity(geom, mat, this.capsule);
        this.particleList = entity.getMesh().geom.vertices.map!(p => new SpringParticle(p.position)).array;
        this.transform = new Transform;
        this.wait = new Wait;
        this.jump = new Jump;
        this.fly = new Fly;
        this.success = new Success;
        this.fail = new Fail;
        this.geom = new GeometricInfo;
    }

    //生成時にElasticSphereいないからやむなし
    void constructor(ElasticSphere elasticSphere) {
        this.elasticSphere = elasticSphere;
    }

    bool canTransform() {
        this.wallContact = this.elasticSphere.getWallContact;
        return this.wallContact.isJust();
    }

    override void initialize(BaseSphere sphere) in {
        assert(sphere is this.elasticSphere);
        assert(this.wallContact.isJust());
    } body {
        auto v = this.wallContact.get().dir;
        auto t = v.getOrtho;
        auto b = cross(t, v).normalize;
        this.entity.obj.pos = this.wallContact.get().pos;
        this.entity.obj.rot = mat3(t, v, b);
        auto length = 
              this.elasticSphere.getParticleList.map!(p => p.position.dot(v)).maxElement
            - this.elasticSphere.getParticleList.map!(p => p.position.dot(v)).minElement;
        auto smallRadius =
            this.elasticSphere.getParticleList.map!((p) {
                auto r = p.position - this.elasticSphere.getCenter;
                r -= dot(r, v) * v;
                return r.length;
            }).maxElement;
        this.geom.init(length, smallRadius, v);
        this.velocity = vec3(0);
        TO_SPEED = 0.9;
        this.stepImpl = transform;
        this.shouldFinish = false;
        parent.world.add(this.entity);
        this.wallContact = None!(ElasticSphere.WallContact);

        this.move();
    }

    override vec3 getCameraTarget() {
        return this.entity.pos + this.entity.rot.column[1] * this.spring.length / 2;
    }

    override void requestLookOver() {
        this.control.lookOver(this.entity.rot.column[1]);
    }

    override BaseSphere move() {
        this.stepImpl.step();
        foreach (p; this.particleList) {
            p.move();
        }
        updateCapsule();
        updateGeometry();
        if (this.shouldFinish) {
            this.elasticSphere.initialize(this);
            parent.world.remove(this.entity);
            return this.elasticSphere;
        }
        return this;
    }

    override BaseSphere onSpringJustRelease() {
        this.stepImpl.onRelease();
        return this;
    }

    override BaseSphere onMovePress(vec2 a) {
        this.geom.axisDif.x.to(a.x);
        this.geom.axisDif.y.to(a.y);
        this.geom.updateAxis();
        auto v = this.geom.axis;
        auto t = v.getOrtho;
        auto b = cross(t, v).normalize;
        this.entity.obj.rot = mat3(t, v, b);
        return this;
    }

    override void setCenter(vec3 center) {
        this.entity.pos = center;
    }

    vec3 getCenter() {
        return this.entity.pos + this.entity.obj.rot.column[1] * this.spring.length / 2;
    }

    vec3 getVelocity() {
        return this.velocity;
    }

    GeometricInfo getGeometricInfo() {
        return this.geom;
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
            v.normal = -safeNormalize(v.normal);
            v.position = p.position;
        }
        geom.updateBuffer();
    }

    private void updateCapsule() {
        this.capsule.setStart(this.entity.pos + this.axis * RADIUS);
        this.capsule.setEnd(this.entity.pos + this.axis * (this.spring.length - RADIUS));
    }

    private void transit(Step step) {
        step.initialize();
        this.stepImpl = step;
    }

    private void finish() {
        this.shouldFinish = true;
    }

    class SpringParticle {
        vec3 position; /* in World, used for Render */
        vec3 normal; /* in World */
        private float theta, phi;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
            this.theta = atan2(p.z, p.x);
            this.phi = atan2(p.y, p.xz.length);
        }

        void move() {
            auto angleSpeed = PI * 2 * geom.spiral;
            auto t = sin(this.phi) * .5 + .5;
            auto angle = t * angleSpeed;
            auto h = t * geom.length;
            auto p = vec3(cos(angle) * geom.largeRadius, h, sin(angle) * geom.largeRadius);
            auto v = vec3(-sin(angle) * angleSpeed, geom.length, cos(angle) * angleSpeed).normalize;
            auto a = v.getOrtho;
            auto b = cross(a, v).normalize;
            this.position = p + geom.smallRadius * cos(this.phi) * (cos(this.theta) * a + sin(this.theta) * b);
            // normal = positionのtheta微分とphi微分の外積方向になるはず
        }
    }

    class GeometricInfo {
        float initialLength;
        float initialSmallRadius;
        float spiral;
        float largeRadius;
        float smallRadius;
        vec3 baseAxis;
        vec2 axisDif;
        vec3 axis;

        void init(float length, float smallRadius, vec3 axis) {
            this.initialLength = spring.length = length;
            this.initialSmallRadius = this.smallRadius = smallRadius;
            this.spiral = 0;
            this.largeRadius = 0;
            this.baseAxis = axis;
            this.axisDif = vec2(0);
        }

        void updateAxis() {
            this.axis = normalize(this.baseAxis + camera.rot * vec3(this.axisDif.x, 0, this.axisDif.y));
        }

        ref float length() {
            return spring.length;
        }
    }

    class Spring {
        private float x;
        private float v;

        this() {
            this.x = 0;
            this.v = 0;
        }

        void setVelocity(float v) {
            this.v = v;
        }

        void step() {
            float d = this.x - BASE_LENGTH;
            float f = -K * d - C * v;
            this.v += f * DELTA_TIME;
            this.x += this.v * DELTA_TIME;
        }

        ref float length() {
            return this.x;
        }

        float getVelocity() {
            return this.v;
        }
    }

    private abstract class Step {
        void initialize(){}
        void onRelease(){}
        abstract void step();
    }

    private class Transform : Step {
        override void step() {
            geom.length.to(SHRINK_LENGTH);
            geom.spiral.to(MAX_SPIRAL);
            geom.largeRadius.to(LARGE_RADIUS);
            geom.smallRadius.to(SMALL_RADIUS);
            if (abs(geom.smallRadius - SMALL_RADIUS) < 0.001) {
                transit(wait);
            }
        }

        override void onRelease() {
            if (abs(geom.smallRadius - SMALL_RADIUS) < 0.1) {
                transit(jump);
            } else {
                transit(fail);
            }
        }
    }

    private class Wait : Step {
        override void step() {
            spring.setVelocity(V0);
        }
        override void onRelease() {
            transit(jump);
        }
    }

    private class Jump : Step {
        override void initialize() {
            spring.setVelocity(V0);
        }
        override void step() {
            spring.step();
            if (spring.length > BASE_LENGTH) {
                velocity = spring.getVelocity() / 2 * entity.obj.rot.column[1];
                transit(fly);
            }
        }
    }

    private class Fly : Step {
        private int count;
        override void initialize() {
            this.count = 6;
        }
        override void step() {
            spring.step();
            velocity += GRAVITY * vec3(0,-1,0) * DELTA_TIME;
            entity.obj.pos += velocity * DELTA_TIME;

            if (count --> 0) {
                TO_SPEED = 0.8;
                transit(success);
            }
        }
    }

    private class Success : Step {
        override void step() {
            velocity += GRAVITY * vec3(0,-1,0) * DELTA_TIME;
            entity.obj.pos += velocity * DELTA_TIME;
            geom.length.to(geom.initialLength);
            geom.spiral.to(0);
            geom.largeRadius.to(0);
            geom.smallRadius.to(geom.initialSmallRadius);
            if (geom.spiral < 0.01) {
                finish();
            }
        }
    }

    private class Fail : Step {
        override void step() {
            geom.length.to(geom.initialLength);
            geom.spiral.to(0);
            geom.largeRadius.to(0);
            geom.smallRadius.to(geom.initialSmallRadius);
            if (geom.spiral < 0.01) {
                finish();
            }
        }
    }

    alias geom this;
}
