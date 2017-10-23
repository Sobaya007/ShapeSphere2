module game.scene.Stage; 

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class Stage : SceneBase {

    mixin SceneBasePack;

    override Maybe!SceneTransition step() {
        return this.finish();
    }
}
