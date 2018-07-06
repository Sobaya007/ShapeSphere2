module sbylib.entity.Mesh; 

import sbylib.camera.Camera;
import sbylib.wrapper.gl.VertexArray;
import sbylib.collision.CollisionEntry;
import std.traits;
import sbylib.utils.Functions;

public {
    import sbylib.geometry.Geometry;
    import sbylib.material.Material;
    import sbylib.entity.Entity;
    import sbylib.core.World;
    import sbylib.material.glsl.UniformDemand;
}

class Mesh {
    Geometry geom;
    Material mat;
    private VertexArray vao;
    private const(Uniform) delegate()[] uniforms;
    private Entity mOwner;

    this(Geometry geom, Material mat, Entity mOwner)
        in(geom !is null)
        in(mat !is null)
        in(mOwner !is null)
    {
        this.geom = geom;
        this.mat = mat;
        this.mOwner = mOwner;
        this.vao = new VertexArray;
        this.vao.setup(mat.program, geom.getBuffers(), geom.getIndexBuffer());
    }

    void destroy() {
        this.vao.destroy();
    }

    void render() {
        this.mat.render(&renderImpl);
    }

    void renderImpl() {
        this.mat.set(this.uniforms);
        this.geom.render(this.vao);
    }

    void setWorld(World world) {
        this.uniforms = null;
        foreach (demand; this.mat.getUniformDemands) {
            final switch (demand) {
            case UniformDemand.World:
                this.uniforms ~= () => this.mOwner.worldMatrix.get();
                break;
            case UniformDemand.View:
            case UniformDemand.Proj:
            case UniformDemand.Light:
                this.uniforms ~= world.getUniform(demand);
                break;
            case UniformDemand.DebugCounter:
                this.uniforms ~= () => this.mat.debugCounter;
                break;
            }
        }
    }

    Entity owner() {
        return this.mOwner;
    }

    override string toString() {
        import std.format;
        import sbylib.utils.Functions;
        return format!"Geom(%s),Mat(%s)"(geom.toString(), mat.toString());
    }
}

class TypedMesh(G, M) : Mesh {

    mixin Proxy;

    @Proxied G geom;
    @Proxied M mat;

    this(G geom, M mat, Entity owner) {
        super(geom, mat, owner);
        this.geom = geom;
        this.mat = mat;
    }
}
