module game.scene.Select;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class Select(Scenes...) : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return this.finish();
    }
}
