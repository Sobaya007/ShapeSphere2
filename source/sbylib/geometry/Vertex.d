module sbylib.geometry.Vertex;

import sbylib.geometry;
import sbylib.math;
import sbylib.wrapper.gl.Attribute;
import sbylib.utils.Functions;

import std.math, std.algorithm, std.array, std.range;
import std.format;

alias VertexV = Vertex!([Attribute.Position]);
alias VertexN = Vertex!([Attribute.Position, Attribute.Normal]);
alias VertexT = Vertex!([Attribute.Position, Attribute.UV]);
alias VertexNT = Vertex!([Attribute.Position, Attribute.Normal, Attribute.UV]);

template GenAttribute(Attribute[] attr) {
    const char[] GenAttribute = attr.map!(a => format!"vec%s %s;"(a.dim, a.name.dropOne())).join("\n");
}

class Vertex(Attribute[] Attributes) {
    mixin(GenAttribute!(Attributes));

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
        auto res = "Vertex {";
        foreach (attr; Utils.Range!(Attribute, Attributes)) {
            res ~= format!"\n  %s = %s"(attr.name, __traits(getMember, this, attr.name.dropOne()).toString());
        }
        res ~= "\n}";
        return res;
    }
}
