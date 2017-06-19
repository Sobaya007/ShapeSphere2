module sbylib.material.glsl.AttributeDemand;

enum AttributeDemand {
    Position,
    Normal,
    UV
}

string getAttributeDemandType(AttributeDemand v) {
    final switch(v) {
    case AttributeDemand.Position:
    case AttributeDemand.Normal:
        return "vec3";
    case AttributeDemand.UV:
        return "vec2";
    }
}

string getAttributeDemandName(AttributeDemand v) {
    final switch(v) {
    case AttributeDemand.Position:
        return "position";
    case AttributeDemand.Normal:
        return "normal";
    case AttributeDemand.UV:
        return "uv";
    }
}
