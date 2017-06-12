module sbylib.utils.customobject.UniformMatrix;

import sbylib.wrapper.gl;
import sbylib.utils.customobject.Uniform;
import derelict.opengl;

import std.string, std.conv;

package class UniformMatrix(uint num) : Uniform {

    extern(System) void function(int, int, ubyte, const(float)*) nothrow @nogc func;

    this(ShaderProgram shader, string name) {
        loc = glGetUniformLocation(shader.programID, name.toStringz);
        assert(loc != -1, name ~ " is not found or used in shader.");
        func = mixin("glUniformMatrix" ~ to!string(num) ~ "fv");
        arguments = new float[num * num];
    }

    override void apply() @nogc {
        func(loc, 1, GL_TRUE, arguments.ptr);
    }
}
