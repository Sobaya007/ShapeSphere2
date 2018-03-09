module sbylib.material.glsl.UniformDemand;

import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.VariableDeclare;
import sbylib.light.PointLight;
import std.format;

enum UniformDemand {
    World,
    View,
    Proj,
    Light,
    DebugCounter
}

string getUniformDemandName(UniformDemand u) {
    final switch(u) {
    case UniformDemand.World:
        return "worldMatrix";
    case UniformDemand.View:
        return "viewMatrix";
    case UniformDemand.Proj:
        return "projMatrix";
    case UniformDemand.Light:
        return "Light";
    case UniformDemand.DebugCounter:
        return "DebugCounter";
    }
}

Statement[] getUniformDemandDeclare(UniformDemand u) {
    final switch (u) {
    case UniformDemand.World:
    case UniformDemand.View:
    case UniformDemand.Proj:
        return [new VariableDeclare(format!"uniform mat4 %s;"(getUniformDemandName(u)))];
    case UniformDemand.Light:
        Statement[] results = [
        new BlockDeclare(PointLightDeclareCode),
        new BlockDeclare(PointLightBlockDeclareCode)];
        return results;
    case UniformDemand.DebugCounter:
        return [new VariableDeclare(format!"uniform int %s;"(getUniformDemandName(u)))];
    }
}
