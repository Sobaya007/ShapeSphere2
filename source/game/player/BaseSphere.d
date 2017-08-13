module game.player.BaseSphere;

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
}
