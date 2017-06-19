module sbylib.material.glsl.UniformDemand;

enum UniformDemand {
    World,
    View,
    Proj,
    Light
}

string getUniformDemandCode(UniformDemand u) {
    final switch(u) {
    case UniformDemand.World:
        return "worldMatrix";
    case UniformDemand.View:
        return "viewMatrix";
    case UniformDemand.Proj:
        return "projMatrix";
    case UniformDemand.Light:
        return "";
    }
}
