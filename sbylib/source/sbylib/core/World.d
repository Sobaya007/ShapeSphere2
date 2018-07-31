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
import sbylib.core.Core;
import sbylib.core.Window;

class World {
    private Entity[] entities;
    private Maybe!Camera mCamera;
    private IRenderGroup[string] renderGroups;
    private Window window;

    this() {
        this(Core().getWindow);
    }

    this(Window window) {
        this.renderGroups["regular"] = new RegularRenderGroup;
        this.window = window;
    }

    Window getWindow() {
        return window;
    }

    /*
       Camera Access
     */
    void setCamera(Camera camera) {
        this.mCamera = Just(camera);
        this.renderGroups["transparent"] = new TransparentRenderGroup(camera);
        this.add(camera);
    }

    Camera camera() {
        return mCamera.unwrap();
    }


    /*
       Entity Management
     */

    void destroy() {
        foreach (e; entities) {
            e.remove();
            e.destroy();
        }
        camera.remove();
        camera.destroy();
    }

    /*
       接続の確立
       entityとそれ以下の子すべてをWorldと接続

       事前条件:
            - entityはWorldと未接続
            - entityは親を持たない

       事後条件:
            - entityはWorldと接続
     */
    auto add(Entity entity)
        in(isConnected(entity) == false, "add's argument must not be added to World")
        in(entity.isParentConnected == false, "add's argument must not have parent")
        out(;isConnected(entity) == true)
    {
        (cast(Entity)entity).traverse((Entity e) {
            this.entities ~= e;
            e.setWorld(this);
            auto groupName = e.mesh.mat.config.renderGroupName;
            if (groupName.isJust) {
                this.renderGroups[groupName.unwrap()].add(e);
            }
        });
        return entity;
    }

    auto add(E)(E entity) if (!is(E == Entity)) {
        add(entity);
        return entity;
    }

    /*
       接続の解消
       entityとそれ以下の子すべてとWorldとの接続を解消

       事前条件:
            - entityはWorldと接続

       事後条件:
            - entityはWorldと未接続
     */
    void remove(Entity entity)
        in(isConnected(entity) == true, "remove's argument must be added to this World")
        out(;isConnected(entity) == false)
    {
        entity.traverse((Entity entity) {
            auto num = this.entities.length;
            this.entities = this.entities.aremove!(e => e == entity);
            assert(this.entities.length == num-1);
            entity.unsetWorld();
            auto groupName = entity.mesh.mat.config.renderGroupName;
            if (groupName.isJust) {
                this.renderGroups[groupName.unwrap()].remove(entity);
            }
        });
    }

    /*
       グループを全消去
       groupNameで示されるグループに属するEntityとの接続が全て解除される

       事前条件:
            - groupNameが正しいグループ名をしていること
     */
    void clear(string groupName)
        in(groupName in this.renderGroups, groupName ~ " is invalid group name")
    {
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

    string[] getRenderGroupNames() {
        return this.renderGroups.keys;
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

    const(Uniform) delegate() getUniform(UniformDemand demand)
        in(this.mCamera.isJust(), "camera is not set.")
    {
        switch (demand) {
        case UniformDemand.View:
            return () => this.mCamera.unwrap().viewMatrix;
        case UniformDemand.Proj:
            return () => this.mCamera.unwrap().projMatrix;
        case UniformDemand.Light:
            return () => PointLightManager().getUniform();
        default:
            assert(false);
        }
    }

    private bool isConnected(Entity e)
        out (connected) {
            import std.array;
            e.getRootParent().traverse((Entity e) {
                assert((this.entities.find(e).empty == false) == connected);
            });
        }
    do {
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
