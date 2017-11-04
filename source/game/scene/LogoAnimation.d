module game.scene.LogoAnimation;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class LogoAnimation : SceneBase {

    mixin SceneBasePack;

    private Process process;
    private Image image;

    this() {
        /*
        this.image = new Image("poyo.png");
        this.setAnimation([
            fade(
                Animation([
                    start(black),
                    end(white),
                    period(1)
                ])
            ),
            this.image.rotate(
                Animation([
                    start(0),
                    end(720),
                    ease(identity),
                    period(2.5)
                ])
            ), 
            this.finish()
        ]);
        */
    }

    override Maybe!SceneTransition step() {
        return this.finish();
    }

    void animate() {
    }
}
