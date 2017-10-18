module game.player.BaseSphere;

import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;

class BaseSphere {

    abstract void initialize(BaseSphere);
    abstract BaseSphere move();
    BaseSphere onDownPress(){return this;}
    BaseSphere onDownJustRelease(){return this;}
    BaseSphere onLeftPress(){return this;}
    BaseSphere onRightPress(){return this;}
    BaseSphere onForwardPress(){return this;}
    BaseSphere onBackPress(){return this;}
    BaseSphere onNeedlePress(){return this;}
    BaseSphere onNeedleRelease(){return this;}
    BaseSphere onSpringPress(){return this;}
    BaseSphere onSpringRelease(){return this;}
    abstract Player.PlayerEntity getEntity();
}
