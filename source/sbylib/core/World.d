module sbylib.core.World;

import sbylib.mesh.Mesh;
import sbylib.camera.Camera;
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
    private Observed!Camera camera; //この変数をwatch対象にするため、どうしてもここに宣言が必要
    private Observer!umat4 viewMatrix;
    private Observer!umat4 projMatrix;
    private Observer!(UniformBuffer!PointLightBlock) pointLightBlockBuffer;
    private Observed!(PointLightBlock) pointLightBlock;

    this() {
        this.camera = new Observed!Camera;
        this.viewMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = this.camera.getObj().viewMatrix;
        }, new umat4("viewMatrix"));
        this.projMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = this.camera.projMatrix;
        }, new umat4("projMatrix"));
        this.pointLightBlock = new Observed!PointLightBlock;
        auto uni = new UniformBuffer!PointLightBlock("PointLightBlock");
        uni.sendData(this.pointLightBlock.get(), BufferUsage.Dynamic);
        this.pointLightBlockBuffer = new Observer!(UniformBuffer!PointLightBlock)((ref UniformBuffer!PointLightBlock uni) {
            PointLightBlock* buffer = uni.map(BufferAccess.Write);
            buffer.num = this.pointLightBlock.num;
            buffer.lights = this.pointLightBlock.lights;
            uni.unmap();
        }, uni);
        this.pointLightBlockBuffer.capture(this.pointLightBlock);
    }

    void setCamera(Camera camera) {
        if (this.camera.get()) {
            this.viewMatrix.release(this.camera.getObj().viewMatrix);
            this.projMatrix.release(this.camera.projMatrix);
        }
        this.camera = camera;
        this.viewMatrix.capture(this.camera.getObj().viewMatrix);
        this.projMatrix.capture(this.camera.projMatrix);
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
        foreach (r; rs) {
            this.entities = this.entities.remove!(e => e == r); //TODO: やばそう？
        }
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
        transparents.sort!((a,b) => dot(camera.getObj.pos - a.pos, a.pos) < dot(camera.getObj.pos - b.pos, b.pos));
        transparents.each!(e => e.render());
    }

    Lazy!Uniform getUniform(UniformDemand demand) {
        switch (demand) {
        case UniformDemand.View:
            return this.viewMatrix.getLazy!Uniform;
        case UniformDemand.Proj:
            return this.projMatrix.getLazy!Uniform;
        case UniformDemand.Light:
            return this.pointLightBlockBuffer.getLazy!Uniform;
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

    CollisionInfoRay[] calcCollideRay(CollisionRay ray) {
        static CollisionInfoRay[] result;
        result.length = 0;
        foreach (entity; this.entities) {
            result ~= entity.collide(ray);
        }
        return result;
    }

    Maybe!CollisionInfoRay rayCast(CollisionRay ray) {
        auto infos = this.calcCollideRay(ray);
        if (infos.length == 0) return None!CollisionInfoRay;
        return Just(infos.minElement!(info => lengthSq(info.point - ray.start)));
    }
}
