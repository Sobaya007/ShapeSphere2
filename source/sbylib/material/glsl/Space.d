module sbylib.material.glsl.Space;

import sbylib.material.glsl.UniformDemand;

enum Space {
    None,
    World,
    View ,
    Proj
}

string getSpaceName(Space s) {
    final switch(s) {
    case Space.None:
        return "";
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
        return [];
    case Space.World:
        return [UniformDemand.World];
    case Space.View:
        return [UniformDemand.View, UniformDemand.World];
    case Space.Proj:
        return [UniformDemand.Proj, UniformDemand.View, UniformDemand.World];
    }
}
