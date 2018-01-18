module game.player.ElasticSphere;

public import game.player.BaseSphere;
public import game.player.NeedleSphere;
public import game.player.SpringSphere;
public import game.player.ElasticSphere2;
import game.Game;
import game.stage.Map;
import game.player.PlayerMaterial;
import game.player.Player;
import game.character.Character;
import game.camera.CameraController;
import game.entity.Message;
import sbylib;
import std.algorithm;
import std.range;
import std.math;
import std.stdio;
import std.typecons;

class ElasticSphere : BaseSphere {

    private static immutable {
        float DOWN_PUSH_FORCE = 600;
        float DOWN_PUSH_FORE_MIN = 800;
        float NORMAL_SIDE_PUSH_FORCE = 10;
        float AIR_SIDE_PUSH_FORCE = 10;
        float SLOW_SIDE_PUSH_FORCE = 2;
    }
    private ElasticSphere2 elasticSphere2;
    private flim pushCount;
    private Player parent;
    private CameraController camera;
    private vec3 _lastDirection;

    alias parent this;

    this(Player parent, CameraController camera)  {
        this.parent = parent;
        this.camera = camera;
        this.pushCount = flim(0.0, 0.0, 1);
        this.elasticSphere2 = new ElasticSphere2();
        this.elasticSphere2.entity.setUserData(parent);
        Game.getWorld3D().add(this.elasticSphere2.entity);
        this._lastDirection = vec3(normalize((camera.pos - this.getCenter).xz), 0).xzy;
    }

    void initialize(NeedleSphere needleSphere) {
        Game.getWorld3D().add(this.elasticSphere2.entity);
        auto arrivalCenter = needleSphere.getCenter();
        auto currentCenter = this.getCenter;
        auto dCenter = arrivalCenter - currentCenter;
        this.elasticSphere2.entity.obj.pos += dCenter;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.position += dCenter;
            particle.velocity = needleSphere.calcVelocity(particle.position);
            particle.capsule.setStart(particle.position);
            particle.capsule.setEnd(particle.position);
        }
        this.pushCount = 0;
    }

    void initialize(SpringSphere springSphere) {
        Game.getWorld3D().add(elasticSphere2.entity);
        auto ginfo = springSphere.getGeometricInfo();
        auto arrivalCenter = springSphere.getCenter();
        auto currentCenter = this.getCenter;
        auto dCenter = arrivalCenter - currentCenter;
        auto height = this.elasticSphere2.getParticleList.map!(p => cast(float)p.position.y).maxElement - this.elasticSphere2.getParticleList.map!(p => cast(float)p.position.y).minElement;
        auto yrate = ginfo.length / height;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.position += dCenter;
            particle.position.y -= arrivalCenter.y;
            particle.position.y *= yrate;
            particle.position.y += arrivalCenter.y;
        }
        this.elasticSphere2.entity.obj.pos += dCenter;
        foreach (particle; this.elasticSphere2.getParticleList) {
            particle.velocity = springSphere.getVelocity();
        }
        this.pushCount = 0;
    }

    override void setCenter(vec3 center) {
        elasticSphere2.setCenter(center);
    }

    override vec3 getCenter() {
        return elasticSphere2.getCenter();
    }

    vec3 getLinearVelocity() {
        return elasticSphere2.getLinearVelocity();
    }

    vec3 getAngularVelocity() {
        return this.elasticSphere2.getAngularVelocity();
    }

    Maybe!(ElasticSphere2.WallContact) getWallContact() {
        return this.elasticSphere2.getWallContact();
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
        this.camera.lookOver(dir);
    }

    override void onDownPress() {
        this.pushCount += 0.1;
        this.elasticSphere2.push(DOWN_PUSH_FORCE * pushCount * vec3(0,-1,0), DOWN_PUSH_FORE_MIN);
    }

    override void onDownJustRelease() {
        this.pushCount = 0;
    }

    override void onMovePress(vec2 v) {
        if (this.camera.isLooking) {
            this.camera.turn(v);
            return;
        }
        this.elasticSphere2.force += this.camera.rot * vec3(v.x, 0, v.y);
    }

    override void onNeedlePress() {
        this.elasticSphere2.entity.remove();
        auto needle = parent.transit!NeedleSphere;
        needle.initialize(this);
    }

    override void onSpringPress() {
        if (this.getWallContact().isNone) return;
        this.elasticSphere2.entity.remove();
        auto springSphere = parent.transit!SpringSphere;
        springSphere.initialize(this);
    }

    override void onDecisideJustPressed() {
        auto info = Array!CollisionInfoByQuery(0);
        scope(exit) info.destroy();
        Game.getWorld3D().queryCollide(info, this.elasticSphere2.entity);
        auto charas = info.map!(colInfo => colInfo.entity.getUserData.fmapAnd!((Variant data) {
            return wrap(data.peek!(Character));
        })).filter!(chara => chara.isJust).map!(chara => chara.get);
        if (charas.empty) return;
        auto chara = charas.front();
        camera.focus(chara.elasticSphere.entity);
        chara.talk(&this.onReturnFromMessage);
    }

    private void onReturnFromMessage() {
        Game.getCommandManager().setReceiver(this);
        this.camera.chase();
    }

    ElasticSphere2.ElasticParticle[] getParticleList() {
        return this.elasticSphere2.getParticleList;
    }

    override void move() {

        this.elasticSphere2.force *= calcSidePushForce();

        this.elasticSphere2.move(parent.collisionEntities);

        if (this.getLinearVelocity.xz.length > 0.5) {
            this._lastDirection = vec3(this.getLinearVelocity.xz.normalize, 0).xzy;
        }
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
