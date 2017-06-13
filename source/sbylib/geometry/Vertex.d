module sbylib.geometry.Vertex;

import sbylib.geometry;
import sbylib.math;
import sbylib.wrapper.gl.Attribute;
import sbylib.utils.Functions;

import std.math, std.algorithm, std.array, std.range;

template GenAttribute(Attribute[] attr) {
    const char[] GenAttribute = attr.map!(a => a.getString()).join("\n");
}

class Vertex(Attribute[] Attributes) {
    const {
        vec3 position;
    }
    mixin(GenAttribute!(Attributes));

    this(vec3 p) {
        this.position = p;
    }

    Vertex!(Attributes2) to(Attribute[] Attributes2)() {
        static names = Attributes.map!(a => a.name).array;
        static names2 = Attributes2.map!(a => a.name).array;
        static intersection = names.filter(name => true);
        Vertex!Attributes2 result;
        mixin((() {
                auto str = "";
                foreach (name; intersection) {
                    str ~= "result." ~ name ~ " = this." ~ name ~ ";";
                }
                    return str;
            })());
    }

    override string toString() {
        auto res = "Vertex {\n\tpos = " ~ this.position.toString();
        foreach (attr; Range!(Attribute, Attributes)) {
            res ~= "\n\t" ~ attr.name ~ " = " ~ __traits(getMember, this, attr.name).toString();
        }
        res ~= "\n}";
        return res;
    }
}

alias VertexV = Vertex!([]);
alias VertexN = Vertex!([Attribute(3, "normal")]);
alias VertexT = Vertex!([Attribute(2, "uv")]);
alias VertexNT = Vertex!([Attribute(3, "normal"), Attribute(2, "uv")]);
