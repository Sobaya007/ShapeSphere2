module game.player.ElasticSphere;

public import game.player.BaseSphere;
public import game.player.NeedleSphere;
public import game.player.SpringSphere;
public import game.player.ElasticSphere2;
import game.player.PlayerMaterial;
import game.player.Player;
import game.player.PlayerChaseControl;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;
import std.typecons;

class ElasticSphere : BaseSphere{

    private static immutable {
        float DOWN_PUSH_FORCE = 600;
        float DOWN_PUSH_FORE_MIN = 800;
        float NORMAL_SIDE_PUSH_FORCE = 10;
        float AIR_SIDE_PUSH_FORCE = 10;
        float SLOW_SIDE_PUSH_FORCE = 2;
    }
    private ElasticSphere2 elasticSphere2;
    private NeedleSphere needleSphere;
    private SpringSphere springSphere;
    private flim pushCount;
    private Player parent;
    private Camera camera;
    private PlayerChaseControl control;
    private World world;
    private vec3 _lastDirection;

    this(Player parent, Camera camera, World world, PlayerChaseControl control)  {
        this.parent = parent;
        this.camera = camera;
        this.world = world;
        this.control = control;
        this.pushCount = flim(0.0, 0.0, 1);
        this.elasticSphere2 = new ElasticSphere2();
        this.world.add(this.elasticSphere2.entity);
        this._lastDirection = vec3(normalize((camera.pos - this.getCenter).xz), 0).xzy;
    }

    //生成時にNeedleSphereとかいないからやむなし
    void constructor(NeedleSphere needleSphere, SpringSphere springSphere) {
        this.needleSphere = needleSphere;
        this.springSphere = springSphere;
    }

    override void initialize(BaseSphere sphere) {
        if (sphere is this.needleSphere) {
            this.fromNeedle();
        } else if (sphere is this.springSphere) {
            this.fromSpring();
        } else {
            assert(false);
        }
    }

    private void fromNeedle() {
        this.parent.world.add(this.elasticSphere2.entity);
        auto arrivalCenter = needleSphere.getCenter();
        auto currentCenter = this.getCenter;
        auto dCenter = arrivalCenter - currentCenter;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.position += dCenter;
        }
        this.elasticSphere2.entity.obj.pos += dCenter;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.velocity = needleSphere.calcVelocity(particle.position);
        }
        this.pushCount = 0;
    }

    private void fromSpring() {
        parent.world.add(elasticSphere2.entity);
        auto ginfo = this.springSphere.getGeometricInfo();
        auto arrivalCenter = this.springSphere.getCenter();
        auto currentCenter = this.getCenter;
        auto dCenter = arrivalCenter - currentCenter;
        auto height = this.elasticSphere2.getParticleList.map!(p => p.position.y).maxElement - this.elasticSphere2.getParticleList.map!(p => p.position.y).minElement;
        auto yrate = ginfo.length / height;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.position += dCenter;
            particle.position.y -= arrivalCenter.y;
            particle.position.y *= yrate;
            particle.position.y += arrivalCenter.y;
        }
        this.elasticSphere2.entity.obj.pos += dCenter;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.velocity = this.springSphere.getVelocity();
        }
        this.pushCount = 0;
    }

    override void setCenter(vec3 center) {
        elasticSphere2.setCenter(center);
    }

    vec3 getCenter() {
        return elasticSphere2.getCenter();
    }

    vec3 getLinearVelocity() {
        return elasticSphere2.getLinearVelocity();
    }

    vec3 getAngularVelocity() {
        return this.elasticSphere2.getAngularVelocity();
    }

    Maybe!(ElasticSphere2.WallContact) getWallContact() {
        return this.elasticSphere2.getWallContact(parent.floors);
    }

    override vec3 getCameraTarget() {
        return this.getCenter;
    }

    override vec3 lastDirection() {
        return this._lastDirection;
    }

    override void requestLookOver() {
        if (!this.elasticSphere2.ground) return;
        auto dir = (this.getCenter - this.camera.pos);
        dir.y = 0;
        dir = normalize(dir);
        this.control.lookOver(dir);
    }

    override BaseSphere onDownPress() {
        this.pushCount += 0.1;
        vec3 g = this.getCenter;
        auto lower = this.calcLower();
        auto upper = this.calcUpper();
        foreach (p; this.elasticSphere2.getParticleList) {
            //下向きの力
            auto len = (p.position - g).xz.length;
            auto t = (p.position.y - lower) / (upper - lower);
            float power = DOWN_PUSH_FORCE / pow(len + 0.6, 2.5);
            power = min(DOWN_PUSH_FORE_MIN, power);
            power *= t;
            p.force.y -= power * this.pushCount;
        }
        return this;
    }
    override BaseSphere onDownJustRelease() {
        this.pushCount = 0;
        return this;
    }

    override BaseSphere onMovePress(vec2 v) {
        if (this.control.isLooking) {
            this.control.turn(v);
            return this;
        }
        this.elasticSphere2.force += this.camera.rot * vec3(v.x, 0, v.y);
        return this;
    }

    override BaseSphere onNeedlePress() {
        this.world.remove(this.elasticSphere2.entity);
        this.needleSphere.initialize(this);
        return this.needleSphere;
    }

    override BaseSphere onSpringPress() {
        if (!this.springSphere.canTransform()) return this;
        this.world.remove(this.elasticSphere2.entity);
        this.springSphere.initialize(this);
        return this.springSphere;
    }

    ElasticSphere2.ElasticParticle[] getParticleList() {
        return this.elasticSphere2.getParticleList;
    }

    override BaseSphere move() {

        this.elasticSphere2.force *= calcSidePushForce();

        this.elasticSphere2.move(parent.floors);

        if (this.getLinearVelocity.xz.length > 0.5) {
            this._lastDirection = vec3(this.getLinearVelocity.xz.normalize, 0).xzy;
        }

        return this;
    }

    float calcLower() {
        return this.elasticSphere2.getParticleList.map!(p => p.position.y).reduce!min;
    }

    float calcUpper() {
        return this.elasticSphere2.getParticleList.map!(p => p.position.y).reduce!max;
    }

    private float calcSidePushForce() {
        if (this.pushCount > 0) {
            return SLOW_SIDE_PUSH_FORCE;
        } else if (elasticSphere2.ground) {
            return NORMAL_SIDE_PUSH_FORCE;
        } else {
            return AIR_SIDE_PUSH_FORCE;
        }
    }

    //山登りで探索
    public ElasticSphere2.ElasticParticle getNearestParticle(vec3 pos) {
        return elasticSphere2.getNearestParticle(pos);
    }

}
