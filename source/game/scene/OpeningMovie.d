module game.scene.OpeningMovie;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class OpeningMovie : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return Just(this.finish());
    }
}
