module sbylib.wrapper.gl.UniformTexture;

import derelict.opengl;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Texture;
import std.string;

alias utexture = UniformTexture;

class UniformTexture : Uniform {

    private string name;
    Texture value;

    this(string name) {
        this.name = name;
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const {
        auto loc = this.getLocation(program);

        glActiveTexture(GL_TEXTURE0 + textureUnit);
        GlFunction.checkError();
        this.value.bind();
        glUniform1i(loc, textureUnit);
        GlFunction.checkError();
        textureUnit++;
    }

    private uint getLocation(const Program program) const out {
        GlFunction.checkError();
    } body {
        int uLoc = glGetUniformLocation(program.id, this.name.toStringz);
        //assert(uLoc != -1, name ~ " is not found or used.");
        return uLoc;
    }

    override string toString() const {
        import std.format;
        if (this.value) {
            return format!"Uniform[%s]: Texture(%d)"(this.name, value.id);
        } else {
            return format!"Uniform[%s]: Texture"(this.name);
        }
    }

    alias value this;
}
