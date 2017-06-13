module sbylib.material.Material;

import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.VertexArray;
import sbylib.utils.Watcher;
import sbylib.material.Constants;
import std.algorithm;
import std.typecons;
import std.array;

alias umat4w = Watcher!(umat4);

abstract class Material {

    const ShaderProgram shader;
    const(Uniform) delegate()[] getUniforms;
    private UniformDemand[] demands;

    this(const ShaderProgram shader) {
        this.shader = shader;
        this.demands = createDemands();
    }

    const(UniformDemand[]) getDemands() {
        return this.demands;
    }

    final void addUniform(const(Uniform) delegate() getUniform) {
        this.getUniforms ~= getUniform;
    }
    final void addUniform(T...)(UniformDemand demand, Watcher!(UniformTemp!T) watcher) {
        this.getUniforms ~= () => watcher.get();
        this.demands = this.demands.remove(demand);
    }

    final void set(Tuple!(Attribute, VertexBuffer)[] buffers) {
        this.shader.use();
        foreach (getUniform; getUniforms) {
            this.shader.attachUniform(getUniform());
        }
    }

    protected abstract UniformDemand[] createDemands();
}
