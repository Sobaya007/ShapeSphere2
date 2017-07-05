module sbylib.collision.CollisionInfo;

import sbylib.collision.CollisionEntry;
import sbylib.math.Vector;

struct CollisionInfo {

    CollisionEntry mesh1, mesh2;
    bool collided;
    vec3 colPoint;
    float colDist;
}
