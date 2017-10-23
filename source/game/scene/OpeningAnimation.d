module game.scene.OpeningAnimation;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class OpeningAnimation : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return this.finish();
    }
}
