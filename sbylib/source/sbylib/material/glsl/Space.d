module sbylib.material.glsl.Space;

import sbylib.material.glsl.UniformDemand;

enum Space {
    None,
    Local,
    World,
    View,
    Proj
}

string getSpaceName(Space s) {
    final switch(s) {
    case Space.None:
        return "";
    case Space.Local:
        return "Local";
    case Space.World:
        return "World";
    case Space.View:
        return "View";
    case Space.Proj:
        return "Proj";
    }
}

UniformDemand[] getUniformDemands(Space s) {
    final switch (s) {
    case Space.None:
    case Space.Local:
        return [];
    case Space.World:
        return [UniformDemand.World];
    case Space.View:
        return [UniformDemand.View, UniformDemand.World];
    case Space.Proj:
        return [UniformDemand.Proj, UniformDemand.View, UniformDemand.World];
    }
}

UniformDemand[] getUniformDemands(Space from, Space to) 
    in(getUniformDemands(from).length <= getUniformDemands(to).length)
{
    auto udFrom = getUniformDemands(from);
    auto udTo = getUniformDemands(to);
    auto num = udTo.length - udFrom.length;
    return udTo[0..num];
}
