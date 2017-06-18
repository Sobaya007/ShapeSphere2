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

    immutable string name;
    Texture value;

    this(string name) {
        this.name = name;
    }

    override string getName() const {
        return this.name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const {
        auto loc = this.getLocation(program);

        glActiveTexture(GL_TEXTURE0 + textureUnit);
        this.value.bind();
        glUniform1i(loc, textureUnit);
        textureUnit++;
    }

    private uint getLocation(const Program program) const {
        int uLoc = glGetUniformLocation(program.id, this.name.toStringz);
        assert(uLoc != -1, name ~ " is not found or used.");
        return uLoc;
    }

    alias value this;
}
