module sbylib.collision.CollisionInfo;

import sbylib.collision.CollisionEntry;
import sbylib.math.Vector;

struct CollisionInfo {
    ICollidable collidable;
    bool collided;
}

struct CollisionInfoRay {
    ICollidable collidable;
    bool collided;
    vec3 colPoint;
    float colDist;
}
