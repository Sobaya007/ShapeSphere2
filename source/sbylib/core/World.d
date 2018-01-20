module sbylib.core.World;

import sbylib.mesh.Mesh;
import sbylib.camera.Camera;
import sbylib.utils.Change;
import sbylib.utils.Lazy;
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

class World {
    private Entity[] entities;
    private ChangeObserved!Camera camera; //この変数をwatch対象にするため、どうしてもここに宣言が必要
    private PointLightBlock pointLightBlock;
    private UniformBuffer!PointLightBlock pointLightBlockBuffer;

    this() {
        this.pointLightBlockBuffer = new UniformBuffer!PointLightBlock("PointLightBlock");
        this.pointLightBlockBuffer.sendData(this.pointLightBlock, BufferUsage.Dynamic);
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
    }

    void add(T)(T[] rs...)
    if (isAssignable!(Entity, T)) in {
    } body{
        foreach (r; rs) {
            this.entities ~= r;
            r.setWorld(this);
        }
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

    void render() {
        auto notTransparents = Array!Entity(0);
        auto transparents = Array!Entity(0);
        scope (exit) {
            notTransparents.destroy();
            transparents.destroy();
        }
        foreach (r; this.entities) {
            r.collect!(mesh => mesh.mat.config.transparency == true)(transparents, notTransparents);
        }
        notTransparents.each!(e => e.render());
        transparents.sort!((a,b) => dot(camera.pos - a.pos, a.pos) < dot(camera.pos - b.pos, b.pos));
        transparents.each!(e => e.render());
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
