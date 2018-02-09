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
import sbylib.core.RenderGroup;

class World {
    private Entity[] entities;
    private Camera camera;
    private PointLightBlock pointLightBlock;
    private UniformBuffer!PointLightBlock pointLightBlockBuffer;
    private IRenderGroup[string] renderGroups;

    this() {
        this.pointLightBlockBuffer = new UniformBuffer!PointLightBlock("PointLightBlock");
        this.pointLightBlockBuffer.sendData(this.pointLightBlock, BufferUsage.Dynamic);
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
        assert(entity.world.get() is this, entity.toString);
    } body {
        auto num = this.entities.length;
        this.entities = this.entities.remove!(e => e == entity);
        assert(this.entities.length == num-1);
        entity.setWorld(None!World);
        auto groupName = entity.mesh.mat.config.renderGroupName;
        if (groupName.isJust) {
            this.renderGroups[groupName.get()].remove(entity);
        }
        entity.getChildren.each!(e => remove(e));
    }

    void clear(string groupName) {
        this.renderGroups[groupName].clear();
        this.entities = this.entities.remove!(e => e.mesh.mat.config.renderGroupName.getOrElse("") == groupName);
    }

    invariant {
        //assert(this.entities.all!(e => e.world.get() is this));
    }

    void addPointLight(PointLight pointLight) {
        this.pointLightBlock.lights[this.pointLightBlock.num++] = pointLight;
    }

    void clearPointLight() {
        this.pointLightBlock.num = 0;
    }

    void addRenderGroup(string name, IRenderGroup group) {
        this.renderGroups[name] = group;
    }

    void render() {
        foreach (groupName; this.renderGroups.byKey) {
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
            return () => this.getPointLightBlockBuffer;
        default:
            assert(false);
        }
    }

    private UniformBuffer!PointLightBlock getPointLightBlockBuffer() {
        PointLightBlock* buffer = this.pointLightBlockBuffer.map(BufferAccess.Write);
        buffer.num = this.pointLightBlock.num;
        buffer.lights = this.pointLightBlock.lights;
        this.pointLightBlockBuffer.unmap();
        return this.pointLightBlockBuffer;
    }

}
