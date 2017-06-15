module sbylib.wrapper.gl.Attribute;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
import std.conv;

struct Attribute {

    enum Position = Attribute(3, "position");
    enum Normal = Attribute(3, "normal");
    enum UV = Attribute(2, "uv");

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
