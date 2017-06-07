module sbylib.gl.Attribute;

import derelict.opengl;
import sbylib.gl.BufferObject;
import sbylib.gl.ShaderProgram;
import std.conv;

struct Attribute {
    immutable {
        uint dim;
        string name;
    }

    this(uint dim, string name) {
        this.dim = dim;
        this.name = name;
    }

    string getString() {
        return "vec" ~ to!string(dim) ~ " " ~ name ~ ";";
    }

    private void enableAttribute(uint loc) {
        glEnableVertexAttribArray(loc);
    }

}
