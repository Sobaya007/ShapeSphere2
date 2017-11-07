module game.scene.Title;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;

class Title : SceneBase {

    mixin SceneBasePack;

    this() {
        auto text = TextEntity("うんこ"d, 0.2);
        super(
            new LoopAnimationSet([
                text.rotate(
                    setting(
                        Radian(0.deg),
                        Radian(360.deg),
                        60,
                        Ease.linear
                    )
                )
            ])
        );
        addEntity(text);
    }
}
