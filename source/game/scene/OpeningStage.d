module game.scene.OpeningStage;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class OpeningStage : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return Just(this.finish());
    }
}
