module sbylib.wrapper.gl.Attribute;

import derelict.opengl;
import sbylib.wrapper.gl.BufferObject;
import std.conv;

struct Attribute {

    enum Position = Attribute(3, "_position");
    enum Normal = Attribute(3, "_normal");
    enum UV = Attribute(2, "_uv");

    immutable {
        uint dim;
        string name;
    }

    this(uint dim, string name) {
        this.dim = dim;
        this.name = name;
    }
}
