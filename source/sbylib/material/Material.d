module sbylib.material.Material;

import sbylib.gl.Uniform;
import sbylib.gl.Shader;
import sbylib.gl.Attribute;
import sbylib.gl.BufferObject;
import sbylib.utils.Watcher;
import std.algorithm;
import std.typecons;
import std.array;

alias uniformMat4fw = Watcher!(uniformMat4f);

abstract class Material {

    immutable ShaderProgram shader;
    immutable(Uniform) delegate()[] getUniforms;

    this(Args...)(immutable ShaderProgram shader, Args uniforms) {
        this.shader = shader;
        foreach (uniform; uniforms) {
            this.getUniforms ~= () => uniform.get;
        }
    }

    void set(Tuple!(Attribute, VertexBuffer)[] buffers) {
        this.shader.use();
        foreach (tuple; buffers) {
            this.shader.attachAttribute(tuple[0], tuple[1]);
        }
        foreach (getUniform; getUniforms) {
            this.shader.attachUniform(getUniform());
        }
    }
}
