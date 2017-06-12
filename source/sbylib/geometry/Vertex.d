module sbylib.geometry.Vertex;

import sbylib.geometry;
import sbylib.math;
import sbylib.wrapper.gl.Attribute;

import std.math, std.algorithm, std.array, std.range;

template GenAttribute(Attribute[] attr) {
    const char[] GenAttribute = attr.map!(a => a.getString()).join("\n");
}

class Vertex(Attribute[] Attributes) {
    immutable {
        vec3 position;
    }
    mixin(GenAttribute!(Attributes));

    this(vec3 p) {
        this.position = p;
    }

    Vertex!(Attributes2) to(string[] Attributes2)() {
        static names = getNames(Attributes);
        static names2 = getNames(Attributes2);
        static intersection = names.filter(name => names2.any!(name2 => name == name2));
        Vertex!Attributes2 result;
        mixin((() {
                auto str = "";
                foreach (name; intersection) {
                    str ~= "result." ~ name ~ " = this." ~ name ~ ";";
                }
                    return str;
            })());
    }
}

alias VertexN = Vertex!([Attribute(3, "normal")]);
alias VertexT = Vertex!([Attribute(2, "uv")]);
alias VertexNT = Vertex!([Attribute(3, "normal"), Attribute(2, "uv")]);
