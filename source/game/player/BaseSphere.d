module game.player.BaseSphere;

import game.player.Player;

interface BaseSphere {

    void move();
    void onDownPress();
    void onDownJustRelease();
    void onNeedlePress();
    void onNeedleRelease();
    void onLeftPress();
    void onRightPress();
    void onForwardPress();
    void onBackPress();
    void leave();
    Player.PlayerEntity getEntity();
}
