module game.player.Particle;

import sbylib;
import std.algorithm;

class Particle {
    vec3 position; /* in World, used for Render */
    vec3 velocity;
    vec3 normal; /* in World */
    vec3 force;
    bool isGround;
    bool isStinger;
    Particle[] next;
    Entity entity;
    CollisionCapsule capsule;

    this(vec3 p) {
        this.position = p;
        this.normal = normalize(p);
        this.velocity = vec3(0,0,0);
        this.force = vec3(0,0,0);
        this.capsule = new CollisionCapsule(0.1, this.position, this.position);
        this.entity = new Entity(this.capsule);
    }
}
