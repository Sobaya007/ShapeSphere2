module sbylib.collision.CollisionInfo;

import sbylib.collision.CollisionEntry;
import sbylib.math.Vector;

struct CollisionInfo {
    CollisionEntry colEntry;
    bool collided;
}

struct CollisionInfoRay {
    CollisionEntry colEntry;
    bool collided;
    vec3 colPoint;
    float colDist;
}
