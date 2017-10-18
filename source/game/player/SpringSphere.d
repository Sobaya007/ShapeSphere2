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

class SpringSphere /*: BaseSphere */{


    static immutable {
        alias TIME_STEP = Player.TIME_STEP;
        float RADIUS = 2.0f;
        uint T_CUT = 20;
        uint P_CUT = 20;
    }

    SpringParticle[] particleList;
    Player.PlayerEntity entity;
    private flim pushCount;
    private Player parent;
    private ElasticSphere.WallContact wallContact;

    this(Player parent)  {
        this.parent = parent;
        this.pushCount = flim(0.0, 0.0, 1);
        auto geom = SphereUV.create!GeometryN(RADIUS, T_CUT, P_CUT);
        auto mat = new Player.Mat();
        mat.ambient = vec3(1);
        this.entity = new Player.PlayerEntity(geom, mat, new CollisionCapsule(RADIUS, vec3(0), vec3(0)));
        this.particleList = entity.getMesh().geom.vertices.map!(p => new SpringParticle(p.position)).array;
    }

//    bool canTransform(ElasticSphere elastic) {
//        this.wallContact = elastic.getWallContact;
//        return this.wallContact.isJust();
//    }
//
//    void fromElastic(ElasticSphere elastic) in {
//        assert(this.wallContact.isJust());
//    } body {
//        // 
//    }
//
//    override void move() in {
//        assert(this.wallContact.isJust());
//    } body {
//        updateGeometry();
//    }
//
//    override void onDownPress() {
//    }
//    override void onDownJustRelease() {
//        this.pushCount = 0;
//    }
//    override void onLeftPress() {
//        this.force -= this.parent.camera.rot.column[0].xyz;
//    }
//    override void onRightPress() {
//        this.force += this.parent.camera.rot.column[0].xyz;
//    }
//    override void onForwardPress() {
//        this.force -= this.parent.camera.rot.column[2].xyz;
//    }
//    override void onBackPress() {
//        this.force += this.parent.camera.rot.column[2].xyz;
//    }
//
//    override void onNeedlePress() {}
//    override void onNeedleRelease(){}
//
//    override Player.PlayerEntity getEntity() {
//        return entity;
//    }
//
//    override void leave() {
//        parent.world.remove(entity);
//    }
//
//    private void updateGeometry() {
//        auto geom = this.entity.getMesh().geom;
//        auto vs = geom.vertices;
//        foreach (ref v; vs) {
//            v.normal = vec3(0);
//        }
//        foreach (face; geom.faces) {
//            auto normal = normalize(cross(
//                    vs[face.indexList[2]].position - vs[face.indexList[0]].position,
//                    vs[face.indexList[1]].position - vs[face.indexList[0]].position));
//            vs[face.indexList[0]].normal += normal;
//            vs[face.indexList[1]].normal += normal;
//            vs[face.indexList[2]].normal += normal;
//        }
//        foreach (i,v; vs) {
//            auto p = this.particleList[i];
//            v.normal = safeNormalize(v.normal);
//            v.position = (this.entity.obj.viewMatrix * vec4(p.position, 1)).xyz;
//        }
//        geom.updateBuffer();
//    }
//
    class SpringParticle {
        vec3 position; /* in World, used for Render */
        vec3 normal; /* in World */
        CollisionCapsule capsule;

        this(vec3 p) {
            this.position = p;
            this.normal = normalize(p);
        }

        void move() {
        }
    }
}
