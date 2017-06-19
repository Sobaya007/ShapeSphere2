module sbylib.core.World;

import sbylib.mesh.Mesh;
import sbylib.camera.Camera;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformBuffer;
import sbylib.wrapper.gl.Viewport;
import sbylib.core.RenderTarget;
import sbylib.light.PointLight;
import sbylib.material.glsl.UniformDemand;
import sbylib.math.Vector;

class World {
    private Mesh[] meshes;
    Watch!Camera camera; //この変数をwatch対象にするため、どうしてもここに宣言が必要
    private Watcher!umat4 viewMatrix;
    private Watcher!umat4 projMatrix;
    private UniformBuffer pointLightBlock;

    this() {
        this.camera = new Watch!Camera;
        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.viewMatrix;
            this.viewMatrix.addWatch(this.camera.viewMatrix);
        }, new umat4("viewMatrix"));
        this.viewMatrix.addWatch(this.camera);
        this.projMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.projMatrix;
            this.projMatrix.addWatch(this.camera.projMatrix);
        }, new umat4("projMatrix"));
        this.projMatrix.addWatch(this.camera);
        this.pointLightBlock = new UniformBuffer("PointLightBlock");
        PointLightBlock block;
        block.num = 1;
        block.lights[0].pos = vec3(1,1,0);
        block.lights[0].diffuse = vec3(1,0,1);
        this.pointLightBlock.sendData(block);
    }

    void addMesh(Mesh mesh) in {
        assert(this.camera.get());
    } body{
        this.meshes ~= mesh;
        foreach (demand; mesh.mat.getDemands()) {
            this.resolveUniformDemand(mesh, demand);
        }
    }

    void render(Viewport viewport, RenderTarget target) {
        target.renderBegin();
        this.render(viewport);
        target.renderEnd();
    }

    void render(Viewport viewport) {
        viewport.set();
        foreach(Mesh m; meshes) {
            m.render();
        }
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
            mesh.mat.setUniform(() => this.pointLightBlock);
            break;
        }
    }
}
