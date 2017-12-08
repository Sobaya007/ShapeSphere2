module game.scene.StartNewGame;

import game.scene.SceneBase;
import sbylib;

class StartNewGame : SceneProtoType {

    mixin SceneBasePack;

    private Label label;
    private uint count;

    this() {
        super();

        this.label = TextEntity("Loading...", 0.3, Label.OriginX.Right, Label.OriginY.Bottom);
        this.label.pos = vec3(1, -1, 0);

        this.addEntity(this.label);
    }

    override void initialize() {
        AnimationManager().startAnimation(
            fade(
                setting(
                    vec4(0),
                    vec4(0,0,0,1),
                    60,
                    Ease.linear
                )
            )
        ).onFinish(&this.finish);
    }
}
