module sbylib.material.glsl.AttributeDemand;

import std.format;

enum AttributeDemand {
    Position,
    Position2,
    Normal,
    UV
}

string getAttributeDemandType(AttributeDemand v) {
    final switch(v) {
    case AttributeDemand.Position:
    case AttributeDemand.Normal:
        return "vec3";
    case AttributeDemand.Position2:
    case AttributeDemand.UV:
        return "vec2";
    }
}

string getAttributeDemandKeyWord(AttributeDemand v) {
    final switch(v) {
    case AttributeDemand.Position:
        return "Position";
    case AttributeDemand.Position2:
        return "Position2";
    case AttributeDemand.Normal:
        return "Normal";
    case AttributeDemand.UV:
        return "UV";
    }
}

string getAttributeDemandName(AttributeDemand v) {
    final switch(v) {
    case AttributeDemand.Position:
    case AttributeDemand.Position2:
        return "_position";
    case AttributeDemand.Normal:
        return "_normal";
    case AttributeDemand.UV:
        return "_uv";
    }
}

string getAttributeDemandBodyExpression(alias replace = s => s)(AttributeDemand v) {
    auto name = replace(getAttributeDemandName(v));
    final switch(v) {
    case AttributeDemand.Position:
        return format!"vec4(%s, 1)"(name);
    case AttributeDemand.Position2:
        return format!"vec4(%s, 0, 1)"(name);
    case AttributeDemand.Normal:
        return format!"vec4(%s, 0)"(name);
    case AttributeDemand.UV:
        return name;
    }
}
