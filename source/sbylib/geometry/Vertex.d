module sbylib.geometry.Vertex;

import sbylib.geometry;
import sbylib.math;
import sbylib.wrapper.gl.Attribute;
import sbylib.utils.Functions;

import std.math, std.algorithm, std.array, std.range;
import std.format;

alias VertexP = Vertex!([Attribute.Position]);
alias VertexN = Vertex!([Attribute.Position, Attribute.Normal]);
alias VertexT = Vertex!([Attribute.Position, Attribute.UV]);
alias VertexNT = Vertex!([Attribute.Position, Attribute.Normal, Attribute.UV]);

template GenAttribute(Attribute[] attr) {
    const char[] GenAttribute = attr.map!(a => format!"vec%s %s;"(a.dim, a.name.dropOne())).join("\n");
}


class Vertex(Attribute[] attr) {

    enum attributes = attr;
    mixin(GenAttribute!(attr));

    this() {}

    //static Vertex!newAttr create(Attribute[] newAttr)(
    template create(NewVertex) {
        mixin(() {
            return format!"
                static NewVertex create(%s) {
                    return new NewVertex(%s);
                }"
                (attr.map!(a => format!"vec%s %s"(a.dim, a.name.dropOne())).join(", "),
                 NewVertex.attributes.map!(a => a.name.dropOne()).join(", "));
                }());
    }

    mixin(() {
        return format!"this(%s) {%s}"(
            attr.map!(a => format!"vec%s %s"(a.dim, a.name.dropOne())).join(", "),
            attr.map!(a => format!"this.%s = %s;"(a.name.dropOne(), a.name.dropOne())).join("\n"));
        }());

    Vertex!(attr2) to(Attribute[] attr2)() {
        static names = attr.map!(a => a.name).array;
        static names2 = attr2.map!(a => a.name).array;
        static intersection = names.filter(name => true);
        Vertex!attr2 result;
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
        foreach (attr; Utils.Range!(Attribute, attr)) {
            res ~= format!"\n  %s = %s"(attr.name, __traits(getMember, this, attr.name.dropOne()).toString());
        }
        res ~= "\n}";
        return res;
    }
}
