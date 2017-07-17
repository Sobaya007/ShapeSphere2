module sbylib.wrapper.gl.UniformBuffer;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import std.string;
import sbylib.math.Vector;

class UniformBuffer(T) : BufferObject!(BufferType.Uniform, T), Uniform {

    string name;

    this(string name) {
        this.name = name;
        super();
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const out {
        GlFunction.checkError();
    } body {
        auto loc = this.getLocation(program);
        glUniformBlockBinding(program.id, loc, uniformBlockPoint);
        glBindBufferBase(BufferType.Uniform, uniformBlockPoint, this.id);
        uniformBlockPoint++;
    }

    private uint getLocation(const Program program) const out {
        GlFunction.checkError();
    } body {
        int uLoc = glGetUniformBlockIndex(program.id, this.name.toStringz);
        assert(uLoc != -1, name ~ " is not found or used."); 
        return uLoc;
    }

}
