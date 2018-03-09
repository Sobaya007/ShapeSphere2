module sbylib.material.glsl.Attribute;

import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import std.conv;
import std.algorithm;
import std.range;

enum Attribute {
    In,
    Out,
    Uniform,
    Const,
    Flat
}

string getAttributeCode(Attribute attr) {
    final switch(attr) {
    case Attribute.In:
        return "in";
    case Attribute.Out:
        return "out";
    case Attribute.Uniform:
        return "uniform";
    case Attribute.Const:
        return "const";
    case Attribute.Flat:
        return "flat";
    }
}
