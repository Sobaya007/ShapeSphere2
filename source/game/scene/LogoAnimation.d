module game.scene.LogoAnimation;

import game.scene.Animation;
import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class LogoAnimation : SceneBase {

    mixin SceneBasePack;

    private Process process;
    private Entity image;

    this() {
        this.image = ImageEntity(ImagePath("uv.png"), 0.2, 0.2);
        super(
            new ThroughAnimationSet([
                fade(
                    setting(
                        vec4(0),
                        vec4(1),
                        10,
                        Ease.identity
                    )
                ),
                this.image.rotate(
                    setting(
                        Radian(0.deg),
                        Radian(720.deg),
                        600,
                        Ease.identity
                    )
                )
            ])
        );
        addEntity(image);
    }
}
