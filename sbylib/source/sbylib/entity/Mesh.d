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
    import sbylib.core.Window;

    Geometry geom;
    Material mat;
    private VertexArray[Window] vao;
    private Uniform delegate()[] uniforms;
    private Entity mOwner;

    this(Geometry geom, Material mat, Entity mOwner)
        in(geom !is null)
        in(mat !is null)
        in(mOwner !is null)
    {
        this.geom = geom;
        this.mat = mat;
        this.mOwner = mOwner;
    }

    void render() {
        this.mat.render(&renderImpl);
    }

    void renderImpl() {

        this.mat.set(this.uniforms);

        VertexArray vao;
        auto current = Window.getCurrentWindow();
        if (current !in this.vao) {
            this.vao[current] = new VertexArray;
            this.vao[current].setup(mat.program, geom.getBuffers(), geom.getIndexBuffer());
        }
        this.geom.render(this.vao[current]);
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
