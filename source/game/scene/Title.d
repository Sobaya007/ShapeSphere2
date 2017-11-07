module game.scene.Title;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class Title : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return Just(this.finish());
    }
}
