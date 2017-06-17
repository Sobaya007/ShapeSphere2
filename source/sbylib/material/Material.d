module sbylib.material.Material;

import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.VertexArray;
import sbylib.utils.Watcher;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.Constants;
import sbylib.material.RenderConfig;
import std.algorithm;
import std.typecons;
import std.array;

alias umat4w = Watcher!(umat4);

abstract class Material {

    const Program shader;
    const(Uniform) delegate()[] getUniforms;
    UniformDemand[] demands;
    RenderConfig config;

    this(const Program shader) {
        this.shader = shader;
        this.demands = createDemands();
        this.config = new RenderConfig();
    }

    final void addUniform(const(Uniform) delegate() getUniform) {
        this.getUniforms ~= getUniform;
    }
    final void addUniform(T...)(Watcher!(UniformTemp!T) watcher) {
        this.getUniforms ~= () => watcher.get();
    }

    final void set() {
        this.config.set();
        this.shader.use();
        uint uniformBlockPoint = 0;
        uint textureUnit = 0;
        foreach (getUniform; getUniforms) {
            getUniform().apply(this.shader, uniformBlockPoint, textureUnit);
        }
    }

    protected abstract UniformDemand[] createDemands();
}
