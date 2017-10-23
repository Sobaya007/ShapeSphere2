module game.scene.LogoAnimation;

import game.scene.Scene;
import sbylib;

class LogoAnimation : SceneBase {

    mixin DeclareCallbacks;

    mixin SetCallbacks;

    public static auto opCall(SceneCallback[] cbs...) {
        return new LogoAnimation(cbs);
    }

    private int count = 0;

    this(SceneCallback[] callbacks...) {
        setCallbacks(callbacks);
    }

    override Maybe!SceneTransition step() {
        if (count < 60) {
            animate();
            return None!SceneTransition;
        }
        return finish();
    }

    void animate() {
    }
}
