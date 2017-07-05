module sbylib.core.World;

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
import sbylib.collision.geometry.CollisionRay;
import sbylib.collision.CollisionEntry;
import std.traits;
import std.algorithm;

class World {
    private Mesh[] meshes;
    private CollisionEntry[] colMeshes;
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

    void addMesh(T)(T[] meshes...) 
    if (isAssignable!(Mesh, T)) in {
        assert(this.camera.get());
    } body{
        this.meshes ~= meshes;
        foreach (mesh; meshes) {
            foreach (demand; mesh.mat.getDemands()) {
                this.resolveUniformDemand(mesh, demand);
            }
        }
    }

    void addColMesh(T)(T[] meshes...)
    if (isAssignable!(CollisionEntry, T)) {
        this.colMeshes ~= meshes;
    }

    void addColMeshAsPolygon(T)(T[] meshes...)
    if (isAssignable!(Mesh, T)) {
        foreach (m; meshes) {
            this.colMeshes ~= m.geom.getCollisionPolygons();
        }
    }

    void addPointLight(PointLight pointLight) {
        this.pointLightBlock.lights[this.pointLightBlock.num++] = pointLight;
    }

    void render(RenderTarget target) {
        target.renderBegin();
        foreach(Mesh m; meshes) {
            m.render();
        }
        target.renderEnd();
    }

    CollisionEntry rayCastMeshes(CollisionRay ray) {
        CollisionEntry result;
        float minDist = 1145141919.0f;
        foreach (c; this.colMeshes) {
            auto colInfo = c.collide(ray);
            if (!colInfo.collided) continue;
            if (minDist < colInfo.colDist) continue;
            minDist = colInfo.colDist;
            result = c;
        }
        return result;
    }

    private void resolveUniformDemand(Mesh mesh, UniformDemand demand) {
        final switch (demand) {
        case UniformDemand.World:
            mesh.mat.setUniform(mesh.obj.worldMatrix);
            break;
        case UniformDemand.View:
            mesh.mat.setUniform(this.viewMatrix);
            break;
        case UniformDemand.Proj:
            mesh.mat.setUniform(this.projMatrix);
            break;
        case UniformDemand.Light:
            mesh.mat.setUniform(this.pointLightBlockBuffer);
            break;
        }
    }
}
