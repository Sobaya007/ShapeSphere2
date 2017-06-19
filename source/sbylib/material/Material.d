module sbylib.material.Material;

import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.VertexArray;
import sbylib.utils.Watcher;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.RenderConfig;
import std.algorithm;
import std.typecons;
import std.array;

alias umat4w = Watcher!(umat4);

abstract class Material {

    const Program shader;
    const(Uniform) delegate()[string] getUniforms;
    RenderConfig config;

    this(const Program shader) {
        this.shader = shader;
        this.config = new RenderConfig();
    }

    final void setUniform(const(Uniform) delegate() getUniform) {
        auto name = getUniform().getName();
        this.getUniforms[name] = getUniform;
    }

    final void setUniform(T...)(Watcher!(UniformTemp!T) watcher) {
        auto name = watcher.get().getName();
        this.getUniforms[name] = () => watcher.get();
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

    abstract UniformDemand[] getDemands();
}
