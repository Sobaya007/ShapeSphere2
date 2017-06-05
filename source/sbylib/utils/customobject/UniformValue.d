module sbylib.utils.customobject.UniformValue;

import sbylib.gl;
import sbylib.utils.customobject.Uniform;
import derelict.opengl;
import std.conv, std.string;

package class UniformValue(uint num) : Uniform {
    extern(System) void function(int, int, const(float)*) nothrow @nogc func;

    this(ShaderProgram shader, string name) {
        loc = glGetUniformLocation(shader.programID, name.toStringz);
        //assert(loc != -1, name ~ " is not found or used in shader.");
        func = mixin("glUniform" ~ to!string(num) ~ "fv");
        arguments = new float[num];
    }

    override void apply() @nogc {
        func(loc, 1, arguments.ptr);
    }
}
