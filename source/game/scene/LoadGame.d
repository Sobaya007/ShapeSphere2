module game.scene.LoadGame;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class LoadGame : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return Just(this.finish());
    }
}
