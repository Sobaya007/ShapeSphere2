module sbylib.light.PointLight;

public {
    import sbylib.math.Vector; 
    import sbylib.wrapper.gl.UniformBuffer;
    import sbylib.entity.Entity;
}
import std.format;

private enum MAX_LIGHT_NUM = 10;

enum PointLightDeclareCode = 
q{
struct PointLight {
    vec3 pos;
    vec3 diffuse;
};
};

enum PointLightBlockDeclareCode = 
format!q{
uniform PointLightBlock {
    int pointLightNum;
    PointLight pointLights[%s];
};
}(MAX_LIGHT_NUM);


class PointLight {

    private vec3 _diffuse;
    Entity entity;
    private size_t index;

    alias entity this;

    this(vec3 pos, vec3 diffuse) {
        import sbylib.geometry.geometry3d.Sphere;
        import sbylib.material.WireframeMaterial;
        debug {
            this.entity = makeEntity(Sphere.create(3, 2), new WireframeMaterial(vec4(vec3(1) - diffuse, 1)));
        } else {
            this.entity = makeEntity();
        }
        this.entity.pos = pos;
        this.diffuse = diffuse;
        auto buffer = PointLightManager().useBlock(BufferAccess.Both);
        this.index = buffer.num++;
        assert(buffer.num <= MAX_LIGHT_NUM);
        buffer.lights[this.index] = Struct(pos, diffuse);

        this.pos.addChangeCallback({
            auto buffer = PointLightManager().useBlock(BufferAccess.Write);
            buffer.lights[this.index].pos = this.pos.get();
        });
    }

    private struct Struct {
        align (16) {
            vec3 pos;
            vec3 diffuse;
        }
    }

    vec3 diffuse() {
        return _diffuse;
    }

    void diffuse(vec3 d) {
        this._diffuse = d;
        auto buffer = PointLightManager().useBlock(BufferAccess.Write);
        buffer.lights[this.index].diffuse = d;
    }
}

class PointLightManager {

    import sbylib.utils.Functions;

    mixin Singleton;
    alias UBlock = UniformBuffer!(Struct);


    enum BlockName = "PointLightBlock";
    private UBlock block;


    private auto useBlock(BufferAccess access) {
        if (block is null) {
            block = new UBlock(BlockName);
            auto s = Struct();
            s.num = 0;
            block.sendData(s);
        }
        struct Po {

            private UBlock block;
            Struct *buffer;

            this(UBlock block, BufferAccess access) {
                this.block = block;
                this.buffer = block.map(access);
            }

            ~this() {
                block.unmap();
            }

            alias buffer this;
        }
        return Po(block, access);
    }

    Uniform getUniform() {
        return this.block;
    }

    void clear() {
        auto buffer = useBlock(BufferAccess.Write);
        buffer.num = 0;
    }

    private struct Struct {
        align (16) {
            int num;
            PointLight.Struct[100] lights;
        }
    }
}
