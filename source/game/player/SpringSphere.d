module game.player.SpringSphere;

public import game.player.BaseSphere;
public import game.player.ElasticSphere;
public import game.player.NeedleSphere;
import game.player.PlayerMaterial;
import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;

private void to(ref float value, float arrival) {
    value = (value - arrival) * 0.9 + arrival;
}

class SpringSphere : BaseSphere {


    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        float RADIUS = 2.0f;
        uint T_CUT = 20;
        uint P_CUT = 80;
        float PERIOD = 0.8;
        float DAMPING_RATIO = 0.3; //減衰比
        float MAX_LENGTH = 10;
        float MAX_SPIRAL = 5;
        float BASE_LENGTH = 5;
        float SHRINK_LENGTH = 1;
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
    private ElasticSphere elasticSphere;
    private flim pushCount;
    private Player parent;
    private Maybe!(ElasticSphere.WallContact) wallContact;
    private float initialSpringLength;
    private float initialSmallRadius;
    private float springLength;
    private float spiral;
    private float largeRadius;
    private float smallRadius;
    private Spring spring;
    private uint phase;
    private float velocity;

    this(Player parent)  {
        this.parent = parent;
        this.spring = new Spring();
        this.pushCount = flim(0.0, 0.0, 1);
        auto geom = SphereUV.create!GeometryN(RADIUS, T_CUT, P_CUT);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.entity = new Player.PlayerEntity(geom, mat, new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.particleList = entity.getMesh().geom.vertices.map!(p => new SpringParticle(p.position)).array;
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
        this.initialSpringLength = 
              this.elasticSphere.getParticleList.map!(p => p.position.y).maxElement
            - this.elasticSphere.getParticleList.map!(p => p.position.y).minElement;
        this.initialSmallRadius =
            this.elasticSphere.getParticleList.map!(p => (p.position - this.elasticSphere.getCenter).xz.length).maxElement;
        this.springLength = this.initialSpringLength;
        this.smallRadius = this.initialSmallRadius;
        this.spiral = 0;
        this.largeRadius = 0;
        this.phase = 0;
        auto v = this.wallContact.get().dir;
        auto t = v.getOrtho;
        auto b = cross(t, v).normalize;
        this.entity.obj.pos = this.wallContact.get().pos;
        this.entity.obj.rot = mat3(t, v, b);
        parent.world.add(this.entity);
        this.wallContact = None!(ElasticSphere.WallContact);

        this.move();
    }

    override BaseSphere move() {
        final switch (this.phase) {
            case 0: //Transforming...
                this.springLength.to(MAX_LENGTH);
                this.spiral.to(MAX_SPIRAL);
                this.largeRadius.to(0.5);
                this.smallRadius.to(0.1);
                if (this.springLength > MAX_LENGTH - 0.01) {
                    this.spring.setLength(this.springLength);
                    this.spring.setVelocity(V0);
                    this.phase++;
                }
                break;
            case 1: //Waiting...
                this.springLength = this.spring.getLength();
                break;
            case 2: //Shrinking...
                this.springLength.to(SHRINK_LENGTH);
                this.spring.setLength(this.springLength);
                break;
            case 3: //Jumping!!!
                this.springLength = this.spring.getLength();
                if (this.springLength > BASE_LENGTH) {
                    this.velocity = this.spring.getVelocity() / 2;
                    this.phase++;
                }
                break;
            case 4: //Flying!!!
                this.entity.obj.pos += this.velocity * DELTA_TIME * this.entity.obj.rot.column[1];
                this.springLength.to(this.initialSpringLength);
                this.spiral.to(0);
                this.largeRadius.to(0);
                this.smallRadius.to(this.initialSmallRadius);
                if (this.spiral < 0.01) {
                    this.elasticSphere.initialize(this);
                    this.parent.world.remove(this.entity);
                    return this.elasticSphere;
                }
                break;
        }
        this.spring.step();
        foreach (p; this.particleList) {
            p.move();
        }
        updateGeometry();
        return this;
    }

    override BaseSphere onSpringPress() {
        this.phase = 0;
        return this;
    }

    override BaseSphere onDownPress() {
        if (this.phase != 1) return this;
        this.phase = 2;
        return this;
    }

    override BaseSphere onDownJustRelease() {
        if (this.phase != 2) return this;
        this.phase = 3;
        return this;
    }

    override Player.PlayerEntity getEntity() {
        return this.entity;
    }

    vec3 getCenter() {
        return this.entity.pos + this.entity.obj.rot.column[1] * this.springLength / 2;
    }

    vec3 getVelocity() {
        return this.velocity * this.entity.rot.column[1];
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

    class SpringParticle {
        vec3 position; /* in World, used for Render */
        vec3 normal; /* in World */
        CollisionCapsule capsule;
        private float theta, phi;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
            this.theta = atan2(p.z, p.x);
            this.phi = atan2(p.y, p.xz.length);
        }

        void move() {
            auto angleSpeed = PI * 2 * spiral;
            auto t = sin(this.phi) * .5 + .5;
            auto angle = t * angleSpeed;
            auto h = t * springLength;
            auto p = vec3(cos(angle) * largeRadius, h, sin(angle) * largeRadius);
            auto v = vec3(-sin(angle) * angleSpeed, springLength, cos(angle) * angleSpeed).normalize;
            auto a = v.getOrtho;
            auto b = cross(a, v).normalize;
            this.position = p + smallRadius * cos(this.phi) * (cos(this.theta) * a + sin(this.theta) * b);
            // normal = positionのtheta微分とphi微分の外積方向になるはず
        }
    }

    class Spring {
        private float x;
        private float v;
        private float f;

        this() {
            this.x = 0;
            this.v = 0;
            this.f = 0;
        }

        void setVelocity(float v) {
            this.v = v;
        }

        void setLength(float x) {
            this.x = x;
        }

        void setForce(float f) {
            this.f = f;
        }

        void step() {
            float d = this.x - BASE_LENGTH;
            float f = -K * d - C * v - this.f;
            this.v += f * DELTA_TIME;
            this.x += this.v * DELTA_TIME;
        }

        float getLength() {
            return this.x;
        }

        float getVelocity() {
            return this.v;
        }
    }
}
