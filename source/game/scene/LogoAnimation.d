module game.scene.LogoAnimation;

import game.scene.SceneBase;
import sbylib;

class LogoAnimation : SceneProtoType {

    mixin SceneBasePack;

    private Entity image;
    this() {
        ImageEntityFactory factory;
        factory.width = 1.8;
        this.image = factory.make(ImagePath("traP.png"));
        super();
        addEntity(image);
    }

    override void initialize() {
        AnimationManager().startAnimation(
            sequence(
                fade(
                    setting(
                        vec4(0,0,0,1),
                        vec4(0,0,0,0),
                        60.frame,
                        &Ease.linear
                    )
                ),
                wait(60.frame),
                fade(
                    setting(
                        vec4(0,0,0,0),
                        vec4(0,0,0,1),
                        60.frame,
                        &Ease.linear
                    )
                ),
            ),
        ).onFinish(&this.finish);
    }
}
