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

    void add(Entity entity) out {
        assert(entity.world.get() is this);
    } body {
        this.entities ~= entity;
        entity.setWorld(Just(this));
        auto groupName = entity.mesh.mat.config.renderGroupName;
        if (groupName.isJust) {
            this.renderGroups[groupName.get()].add(entity);
        }
        entity.getChildren.each!(e => add(e));
    }

    void remove(Entity entity) in {
        assert(entity.world.isJust && entity.world.get() is this, entity.toString);
    } body {
        import std.format;
        auto num = this.entities.length;
        this.entities = this.entities.aremove!(e => e == entity);
        //assert(this.entities.length == num-1, format!"before: %d, after: %d\nremoved was %s"(num, this.entities.length, entity.toString));
        entity.setWorld(None!World);
        auto groupName = entity.mesh.mat.config.renderGroupName;
        if (groupName.isJust) {
            this.renderGroups[groupName.get()].remove(entity);
        }
        entity.getChildren.each!(e => remove(e));
    }

    void clear(string groupName) {
        this.renderGroups[groupName].clear();
        this.entities = this.entities.aremove!(e => e.mesh.mat.config.renderGroupName.getOrElse("") == groupName);
    }

    Entity[] getEntities() {
        return entities;
    }

    invariant {
        //assert(this.entities.all!(e => e.world.get() is this));
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
}
