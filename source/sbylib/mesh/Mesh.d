module sbylib.mesh.Mesh;

import sbylib.camera.Camera;
import sbylib.wrapper.gl.VertexArray;
import sbylib.collision.CollisionEntry;
import std.traits;

public {
    import sbylib.geometry.Geometry;
    import sbylib.material.Material;
    import sbylib.core.Entity;
    import sbylib.core.World;
    import sbylib.material.glsl.UniformDemand;
}

class Mesh {
    Geometry geom;
    Material mat;
    private VertexArray vao;
    Uniform delegate()[string] getUniforms;
    private Entity owner;

    this(Geometry geom, Material mat, Entity owner) {
        this.geom = geom;
        this.mat = mat;
        this.owner = owner;
        this.vao = new VertexArray;
        this.vao.setup(mat.shader, geom.getBuffers(), geom.getIndexBuffer());
    }

    void render() in {
        assert(this.geom);
        assert(this.mat);
    } body{
        this.mat.set(this.getUniforms);
        this.geom.render(this.vao);
    }

    void onSetWorld(World world) {
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

    Entity getOwner() {
        return this.owner;
    }
}

class MeshTemp(G, M) : Mesh {

    G geom;
    M mat;

    this(G geom, Entity owner) {
        this(geom, new M, owner);
    }

    this(G geom, M mat, Entity owner) {
        super(geom, mat, owner);
        this.geom = geom;
        this.mat = mat;
    }
}
