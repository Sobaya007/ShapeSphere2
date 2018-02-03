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

    private UniformBuffer!PointLightBlock getPointLightBlockBuffer() {
        PointLightBlock* buffer = this.pointLightBlockBuffer.map(BufferAccess.Write);
        buffer.num = this.pointLightBlock.num;
        buffer.lights = this.pointLightBlock.lights;
        this.pointLightBlockBuffer.unmap();
        return this.pointLightBlockBuffer;
    }

    void setCamera(Camera camera) {
        this.camera = camera;
        this.renderGroups["transparent"] = new TransparentRenderGroup(camera);
    }

    void addRenderGroup(string name, IRenderGroup group) {
        this.renderGroups[name] = group;
    }

    void add(Entity entity) {
        add(entity, entity.getMesh().mat.config.transparency.fmap!(b => b ? "regular" : "transparent"));
    }

    void add(Entity entity, Maybe!(string) groupName) {
        this.entities ~= entity;
        entity.setWorld(this);
        if (groupName.isNone) return;
        this.renderGroups[groupName.get()].add(entity);
    }

    void remove(T)(T[] rs...)
    if (isAssignable!(Entity, T)) in {
    } body{
        auto len = this.entities.length;
        foreach (r; rs) {
            this.entities = this.entities.remove!(e => e == r); //TODO: やばそう？
        }
        assert(len == rs.length + this.entities.length);
    }

    void addPointLight(PointLight pointLight) {
        this.pointLightBlock.lights[this.pointLightBlock.num++] = pointLight;
    }

    void clearPointLight() {
        this.pointLightBlock.num = 0;
    }

    void render() {
        foreach (groupName; this.renderGroups.byKey) {
            this.render(groupName);
        }
    }

    void render(string groupName) {
        this.renderGroups["regular"].render();
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
}
