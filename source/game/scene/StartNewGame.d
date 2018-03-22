module game.scene.StartNewGame;

import game.scene.SceneBase;
import sbylib;

class StartNewGame : SceneProtoType {

    mixin SceneBasePack;

    private Label label;
    private uint count;

    this() {
        super();

        LabelFactory factory;
        factory.text = "Loading...";
        factory.height = 0.3;
        this.label = factory.make();
        this.label.right = 1;
        this.label.bottom = -1;

        this.addEntity(this.label);
    }

    override void initialize() {
        AnimationManager().startAnimation(
            fade(
                setting(
                    vec4(0),
                    vec4(0,0,0,1),
                    60.frame,
                    &Ease.linear
                )
            )
        ).onFinish(&this.finish);
    }
}
