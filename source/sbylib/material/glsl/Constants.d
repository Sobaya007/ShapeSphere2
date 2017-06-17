module sbylib.material.glsl.Constants;

enum StructType {
    Struct = "struct",
    Uniform = "uniform",
}

enum Type : string {
    Void = "void",
    Float = "float",
    Vec2 = "vec2",
    Vec3 = "vec3",
    Vec4 = "vec4",
    Mat2 = "mat2",
    Mat3 = "mat3",
    Mat4 = "mat4",
}

enum VaryingDemand : string {
    Position = "Position",
    Normal = "Normal",
    UV = "UV"
}

enum UniformDemand : string {
    World = "WorldMatrix",
    View = "ViewMatrix",
    Proj = "ProjMatrix"
}

enum Space : string {
    None = "",
    World = "World",
    View = "View",
    Proj = "Proj"
}
