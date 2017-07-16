module sbylib.mesh.Mesh;

import sbylib.camera.Camera;
import sbylib.wrapper.gl.VertexArray;
import sbylib.collision.CollisionEntry;
import std.traits;

public {
    import sbylib.geometry.Geometry;
    import sbylib.material.Material;
    import sbylib.core.Entity;
    import sbylib.core.Bahamut;
    import sbylib.material.glsl.UniformDemand;
}

class Mesh {
    Geometry geom;
    Material mat;
    private VertexArray vao;
    private Uniform delegate()[string] getUniforms;
    private Entity owner;

    this(Geometry geom, Material mat) {
        this.geom = geom;
        this.mat = mat;
        this.vao = new VertexArray;
        this.vao.setup(mat.shader, geom.getBuffers(), geom.getIndexBuffer());
    }

    void setOwner(Entity owner) {
        this.owner = owner;
    }

    void render() in {
        assert(this.geom);
        assert(this.mat);
    } body{
        this.mat.set(this.getUniforms);
        this.geom.render(this.vao);
    }

    void onSetWorld(Bahamut world) {
        foreach (demand; this.mat.getDemands()) {
            final switch (demand) {
            case UniformDemand.World:
                this.setUniform(() => this.owner.obj.worldMatrix.get());
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
}

class MeshTemp(G, M) : Mesh {

    G geom;
    M mat;

    this(G geom) {
        this(geom, new M);
    }

    this(G geom, M mat) {
        super(geom, mat);
        this.geom = geom;
        this.mat = mat;
    }
}
