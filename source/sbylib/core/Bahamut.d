module sbylib.core.Bahamut;

import sbylib.mesh.Mesh;
import sbylib.camera.Camera;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformBuffer;
import sbylib.core.RenderTarget;
import sbylib.light.PointLight;
import sbylib.material.glsl.UniformDemand;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;
import sbylib.geometry.Geometry;
import std.traits;
import std.algorithm;

class Bahamut {
    private Entity[] entities;
    Watch!Camera camera; //この変数をwatch対象にするため、どうしてもここに宣言が必要
    private Watcher!umat4 viewMatrix;
    private Watcher!umat4 projMatrix;
    private Watcher!(UniformBuffer!PointLightBlock) pointLightBlockBuffer;
    private Watch!(PointLightBlock) pointLightBlock;

    this() {
        this.camera = new Watch!Camera;
        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.getObj().viewMatrix;
            this.viewMatrix.addWatch(this.camera.getObj().viewMatrix);
        }, new umat4("viewMatrix"));
        this.viewMatrix.addWatch(this.camera);
        this.projMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.projMatrix;
            this.projMatrix.addWatch(this.camera.projMatrix);
        }, new umat4("projMatrix"));
        this.projMatrix.addWatch(this.camera);
        this.pointLightBlock = new Watch!PointLightBlock;
        auto uni = new UniformBuffer!PointLightBlock("PointLightBlock");
        uni.sendData(this.pointLightBlock.get(), BufferUsage.Dynamic);
        this.pointLightBlockBuffer = new Watcher!(UniformBuffer!PointLightBlock)((ref UniformBuffer!PointLightBlock uni) {
            PointLightBlock* buffer = uni.map(BufferAccess.Write);
            buffer.num = this.pointLightBlock.num;
            buffer.lights = this.pointLightBlock.lights;
            uni.unmap();
        }, uni);
        this.pointLightBlockBuffer.addWatch(this.pointLightBlock);
    }

    void add(T)(T[] rs...) 
    if (isAssignable!(Entity, T)) in {
    } body{
        foreach (r; rs) {
            this.entities ~= r;
            r.setWorld(this);
        }
    }

    void addPointLight(PointLight pointLight) {
        this.pointLightBlock.lights[this.pointLightBlock.num++] = pointLight;
    }

    void render(RenderTarget target) {
        target.renderBegin();
        foreach (r; this.entities) {
            if (auto mesh = r.getMesh()) {
                mesh.render();
            }
        }
        target.renderEnd();
    }

    Uniform delegate() getUniform(UniformDemand demand) {
        switch (demand) {
        case UniformDemand.View:
            return () => this.viewMatrix;
        case UniformDemand.Proj:
            return () => this.projMatrix;
        case UniformDemand.Light:
            return () => this.pointLightBlockBuffer;
        default:
            assert(false);
        }
    }

    CollisionInfo[] calcCollide(CollisionEntry colEntry) {
        static CollisionInfo[] result;
        result.length = 0;
        foreach (entity; this.entities) {
            if (auto c = entity.getCollisionEntry()) {
                auto colInfo = c.collide(colEntry);
                if (!colInfo.collided) continue;
                result ~= colInfo;
            }
        }
        return result;
    }

    CollisionInfoRay calcCollideRay(CollisionRay ray) {
        CollisionInfoRay result;
        result.colDist = 1145141919.324;
        foreach (entity; this.entities) {
            if (auto c = entity.getCollisionEntry()) {
                auto colInfo = c.collide(ray);
                if (!colInfo.collided) continue;
                if (result.colDist < colInfo.colDist) continue;
                result = colInfo;
            }
        }
        return result;
    }
}
