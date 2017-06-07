module sbylib.geometry.Vertex;

import sbylib.geometry;
import sbylib.math;

import std.math, std.algorithm, std.array, std.range;

template GenAttribute(string[] attr) {
    const types = getTypes(attr);
    const names = getNames(attr);
    const char[] GenAttribute = zip(types, names).map!(a => a[0] ~ " " ~ a[1] ~ ";").join("\n");
}

class Vertex(string[] Attributes) {
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

alias VertexN = Vertex!(["vec3", "normal"]);
alias VertexT = Vertex!(["vec2", "uv"]);
alias VertexNT = Vertex!(["vec3", "normal", "vec2", "uv"]);

private static string[] getTypes(string[] attr) {
    assert(attr.length % 2 == 0);
    string[] types;
    foreach (i; 0..attr.length/2) {
        types ~= attr[i*2];
    }
    return types;
}

private static string[] getNames(string[] attr) {
    assert(attr.length % 2 == 0);
    string[] names;
    foreach (i; 0..attr.length/2) {
        names ~= attr[i*2+1];
    }
    return names;
}
