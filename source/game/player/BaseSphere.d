module game.player.BaseSphere;

import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;

class BaseSphere {

    abstract void initialize(BaseSphere);
    abstract BaseSphere move();
    abstract vec3 getCameraTarget();
    BaseSphere onDownPress(){return this;}
    BaseSphere onDownJustRelease(){return this;}
    BaseSphere onMovePress(vec2) {return this;}
    BaseSphere onNeedlePress(){return this;}
    BaseSphere onNeedleRelease(){return this;}
    BaseSphere onSpringPress(){return this;}
    BaseSphere onSpringJustRelease(){return this;}
}
