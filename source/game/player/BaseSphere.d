module game.player.BaseSphere;

import game.player.Player;
import sbylib;
import std.algorithm;
import std.range;

class BaseSphere { 
    abstract void move();
    abstract vec3 getCameraTarget();
    abstract vec3 lastDirection();
    abstract void setCenter(vec3);
    abstract vec3 getCenter();
    void requestLookOver(){}
    void onDownPress(){}
    void onDownJustRelease(){}
    void onMovePress(vec2) {}
    void onNeedlePress(){}
    void onNeedleRelease(){}
    void onSpringPress(){}
    void onSpringJustRelease(){}
    void onDecisideJustPressed(){}
}
