module game.player.Particle;

import sbylib;
import std.algorithm;

class Particle {
    vec3 position;
    vec3 velocity;
    vec3 normal;
    vec3 force;
    vec3 extForce;
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
        this.extForce = vec3(0,0,0);
        this.capsule = new CollisionCapsule(0.1, this.position, this.position);
        this.entity = new Entity(this.capsule);
    }
}
