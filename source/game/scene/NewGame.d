module game.scene.NewGame;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class NewGame : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return Just(this.finish());
    }
}
