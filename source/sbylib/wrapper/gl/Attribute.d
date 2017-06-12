module sbylib.wrapper.gl.Attribute;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
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
}
