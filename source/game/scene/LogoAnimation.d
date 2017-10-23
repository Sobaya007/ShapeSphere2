module game.scene.LogoAnimation;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class LogoAnimation : SceneBase {

    mixin SceneBasePack;

    private int count = 0;

    override Maybe!SceneTransition step() {
        if (count < 60) {
            animate();
            return None!SceneTransition;
        }
        return this.finish();
    }

    void animate() {
    }
}
