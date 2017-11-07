module game.scene.LogoAnimation;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class LogoAnimation : SceneBase {

    mixin SceneBasePack;

    this() {
        auto image = ImageEntity(ImagePath("uv.png"), 0.2, 0.2);
        super(
            new ThroughAnimationSet([
                fade(
                    setting(
                        vec4(0,0,0,1),
                        vec4(0,0,0,0),
                        60,
                        Ease.linear
                    )
                ),
                image.rotate(
                    setting(
                        Radian(0.deg),
                        Radian(360.deg),
                        60,
                        Ease.easeInOut
                    )
                ),
                fade(
                    setting(
                        vec4(0,0,0,0),
                        vec4(0,0,0,1),
                        60,
                        Ease.linear
                    )
                ),
            ])
        );
        addEntity(image);
    }
}
