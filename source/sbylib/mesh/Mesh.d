module sbylib.mesh.Mesh;

import sbylib.mesh.IMesh;
import sbylib.mesh.Object3D;
import sbylib.geometry.Geometry;
import sbylib.material.Material;
import sbylib.camera.Camera;
import sbylib.wrapper.gl.VertexArray;
import sbylib.collision.CollisionEntry;
import std.traits;

class Mesh : IMesh {
    Object3D obj;
    Geometry geom;
    Material mat;
    private VertexArray vao;
    private Uniform delegate()[string] getUniforms;

    this(Geometry geom, Material mat, Object3D obj = new Object3D) {
        this.obj = obj;
        this.geom = geom;
        this.mat = mat;
        this.vao = new VertexArray;
        this.vao.setup(mat.shader, geom.getBuffers(), geom.getIndexBuffer());
    }

    override void render() in {
        assert(this.geom);
        assert(this.mat);
    } body{
        this.mat.set(this.getUniforms);
        this.geom.render(this.vao);
    }

    override void resolveEnvironment(Bahamut world) {
        foreach (demand; this.mat.getDemands()) {
            final switch (demand) {
            case UniformDemand.World:
                this.setUniform(() => this.obj.worldMatrix.get());
                break;
            case UniformDemand.View:
            case UniformDemand.Proj:
            case UniformDemand.Light:
                this.setUniform(world.getUniform(demand));
                break;
            }
        }
        foreach (uni; this.mat.getUniforms()) {
            (u) {
                this.setUniform(() => u);
            }(uni);
        }
    }

    final void setUniform(Uniform delegate() getUniform) {
        auto name = getUniform().getName();
        this.getUniforms[name] = getUniform;
    }

    override void setParent(Object3D parent) {
        this.obj.setParent(parent);
    }

    CollisionEntryGroup createCollisionPolygons() {
        return this.geom.createCollisionPolygons(this.obj);
    }
}

class MeshTemp(G, M, O = Object3D) : Mesh {

    G geom;
    M mat;
    O obj;

    this(G geom, O obj = new O) {
        this(geom, new M, obj);
    }

    this(G geom, M mat, O obj = new O) {
        super(geom, mat, obj);
        this.geom = geom;
        this.mat = mat;
        this.obj = obj;
    }
}

class MeshGroup : IMesh {
    private IMesh[] renderables;
    Object3D obj;
    private Bahamut bahamut;

    this() {
        this.obj = new Object3D();
    }

    void add(IMesh r) {
        this.renderables ~= r;
        r.setParent(this.obj);
        if (this.bahamut !is null) {
            r.resolveEnvironment(this.bahamut);
        }
    }

    void clear() {
        this.renderables.length = 0;
    }

    override void render() {
        foreach (r; this.renderables) {
            r.render();
        }
    }

    override void resolveEnvironment(Bahamut world) {
        this.bahamut = world;
        foreach (r; this.renderables) {
            r.resolveEnvironment(world);
        }
    }

    override void setParent(Object3D parent) {
        this.obj.setParent(parent);
    }
}
