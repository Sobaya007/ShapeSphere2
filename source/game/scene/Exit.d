module game.scene.Exit;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class Exit : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return this.finish();
    }
}
