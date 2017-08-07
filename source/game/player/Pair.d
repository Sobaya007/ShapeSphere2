module game.player.Pair;

import game.player.Particle;

struct Pair {
    Particle p0, p1;

    this(Particle p0, Particle p1) {
        this.p0 = p0;
        this.p1 = p1;
    }
}
