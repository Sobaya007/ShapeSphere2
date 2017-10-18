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

class SpringSphere : BaseSphere {


    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        float RADIUS = 2.0f;
        uint T_CUT = 20;
        uint P_CUT = 80;
    }

    private SpringParticle[] particleList;
    private Player.PlayerEntity entity;
    private ElasticSphere elasticSphere;
    private flim pushCount;
    private Player parent;
    private Maybe!(ElasticSphere.WallContact) wallContact;
    private float springLength;
    private float spiral;
    private float largeRadius;
    private float smallRadius;

    this(Player parent)  {
        this.parent = parent;
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
        this.springLength = 3;
        this.spiral = 5;
        this.largeRadius = 1;
        this.smallRadius = 0.1;

        this.springLength = 
              this.elasticSphere.getParticleList.map!(p => p.position.y).maxElement
            - this.elasticSphere.getParticleList.map!(p => p.position.y).minElement;
        this.spiral = 0;
        this.largeRadius = 0;
        this.smallRadius =
            this.elasticSphere.getParticleList.map!(p => (p.position - this.elasticSphere.getCenter).xz.length).maxElement;
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
        foreach (p; this.particleList) {
            p.move();
        }
        updateGeometry();
        return this;
    }

    override BaseSphere onSpringPress() {
        this.springLength = 3;
        this.spiral = 5;
        this.largeRadius = 1;
        this.smallRadius = 0.1;
        return this;
    }

    override BaseSphere onSpringRelease(){
        this.parent.world.remove(this.entity);
        this.elasticSphere.initialize(this);
        return this.elasticSphere;
    }

    override Player.PlayerEntity getEntity() {
        return this.elasticSphere.getEntity;
    }

    private void updateGeometry() {
        auto geom = this.entity.getMesh().geom;
        auto vs = geom.vertices;
        foreach (i,v; vs) {
            auto p = this.particleList[i];
            v.normal = -p.normal; // why reverse???
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
            auto c = -sin(this.theta) * a + cos(this.theta) * b;
            auto d = vec3(0, cos(this.phi) * .5 * springLength, 0) + smallRadius * -sin(this.phi) * (cos(this.theta) * a + sin(this.theta) * b);
            this.normal = cross(d,c).normalize;
        }
    }
}
