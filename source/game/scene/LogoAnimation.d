module game.scene.LogoAnimation;

import game.scene.SceneBase;
import sbylib;

class LogoAnimation : SceneProtoType {

    mixin SceneBasePack;

    private Entity image;
    this() {
        this.image = makeImageEntity(ImagePath("uv.png"), 0.2, 0.2);
        super();
        addEntity(image);
    }

    override void initialize() {
        AnimationManager().startAnimation(
            sequence([
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
            ]),
        ).onFinish(&this.finish);
    }
}
