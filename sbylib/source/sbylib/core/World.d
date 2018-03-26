module sbylib.core.World;

import sbylib.entity.Mesh;
import sbylib.camera.Camera;
import sbylib.utils.Change;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformBuffer;
import sbylib.render.RenderTarget;
import sbylib.light.PointLight;
import sbylib.material.glsl.UniformDemand;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;
import sbylib.geometry.Geometry;
import sbylib.utils.Array;
import sbylib.utils.Maybe;
import std.traits;
import std.algorithm;
import std.algorithm : aremove = remove;
import sbylib.core.RenderGroup;

class World {
    private Entity[] entities;
    private Camera camera;
    private IRenderGroup[string] renderGroups;

    this() {
        this.renderGroups["regular"] = new RegularRenderGroup;
    }

    /*
       Camera Access
     */
    void setCamera(Camera camera) {
        this.camera = camera;
        this.renderGroups["transparent"] = new TransparentRenderGroup(camera);
    }

    Camera getCamera() {
        return camera;
    }


    /*
       Entity Management
     */

    /*
       接続の確立
       entityとそれ以下の子すべてをWorldと接続

       事前条件:
            - entityはWorldと未接続
            - entityは親を持たない

       事後条件:
            - entityはWorldと接続
     */
    void add(Entity entity) in {
        assert(isConnected(entity) == false, "add's argument must not be added to World");
        assert(entity.isParentConnected == false, "add's argument must not have parent");
    } out {
        assert(isConnected(entity) == true);
    } body {
        entity.traverse((Entity e) {
            this.entities ~= e;
            e.setWorld(this);
            auto groupName = e.mesh.mat.config.renderGroupName;
            if (groupName.isJust) {
                this.renderGroups[groupName.get()].add(e);
            }
        });
    }

    /*
       接続の解消
       entityとそれ以下の子すべてとWorldとの接続を解消

       事前条件:
            - entityはWorldと接続

       事後条件:
            - entityはWorldと未接続
     */
    void remove(Entity entity) in {
        assert(isConnected(entity) == true, "remove's argument must be added to this World");
    } out {
        assert(isConnected(entity) == false);
    } body {
        entity.traverse((Entity entity) {
            auto num = this.entities.length;
            this.entities = this.entities.aremove!(e => e == entity);
            assert(this.entities.length == num-1);
            entity.unsetWorld();
            auto groupName = entity.mesh.mat.config.renderGroupName;
            if (groupName.isJust) {
                this.renderGroups[groupName.get()].remove(entity);
            }
        });
    }

    /*
       グループを全消去
       groupNameで示されるグループに属するEntityとの接続が全て解除される

       事前条件:
            - groupNameが正しいグループ名をしていること
     */
    void clear(string groupName) in {
        assert(groupName in this.renderGroups, groupName ~ " is invalid group name");
    } body {
        this.renderGroups[groupName].clear();
        this.entities.filter!(e => e.mesh.mat.config.renderGroupName.getOrElse("") == groupName)
            .each!(e => e.unsetWorld());
        this.entities = this.entities.aremove!(e => e.mesh.mat.config.renderGroupName.getOrElse("") == groupName);
    }

    Entity[] getEntities() {
        return entities;
    }

    debug int getEntityNum() {
        return entities.filter!(e => e.getParent.isNone).map!(e => e.getDescendantNum).sum;
    }

    void addRenderGroup(string name, IRenderGroup group) {
        this.renderGroups[name] = group;
    }

    void render() {
        foreach_reverse (groupName; this.renderGroups.keys) {
            this.render(groupName);
        }
    }

    void render(string groupName) {
        this.renderGroups[groupName].render();
    }

    void queryCollide(ref Array!CollisionInfoByQuery result, Entity colEntry) {
        auto po = Array!CollisionInfo(0);
        scope(exit) po.destroy();
        foreach (entity; this.entities) {
            entity.collide(po, colEntry);
        }
        while (!po.empty) {
            auto colInfo = po.front();
            result ~= CollisionInfoByQuery(colInfo.getOther(colEntry), colInfo.getDepth(), colInfo.getPushVector(colEntry));
            po.popFront();
        }
    }

    void calcCollideRay(ref Array!CollisionInfoRay result, CollisionRay ray) {
        foreach (entity; this.entities) {
            entity.collide(result, ray);
        }
    }

    Maybe!CollisionInfoRay rayCast(CollisionRay ray) {
        auto infos = Array!CollisionInfoRay(0);
        scope(exit) infos.destroy();
        this.calcCollideRay(infos, ray);
        if (infos.length == 0) return None!CollisionInfoRay;
        return Just(infos.minElement!(info => lengthSq(info.point - ray.start)));
    }

    const(Uniform) delegate() getUniform(UniformDemand demand) {
        switch (demand) {
        case UniformDemand.View:
            return () => this.camera.viewMatrix;
        case UniformDemand.Proj:
            return () => this.camera.projMatrix;
        case UniformDemand.Light:
            return () => PointLightManager().getUniform();
        default:
            assert(false);
        }
    }

    private bool isConnected(Entity e) out (connected) {
        import std.array;
        e.getRootParent().traverse((Entity e) {
            assert((this.entities.find(e).empty == false) == connected);
        });
    } body {
        import std.algorithm, std.array;
        return this.entities.find(e).empty == false;
    }

    auto findByName(string name) {
        return entities.filter!(e => e.name == name);
    }

    auto getEntityNames() {
        import std.array;
        return entities.map!(e => e.name).array;
    }

    override string toString() {
        return toString((Entity e) => e.toString, true);
    }

    string toString(string function(Entity) func, bool recursive) {
        import std.array;
        return entities.map!(e => e.toString(func, recursive)).join('\n');
    }
}
