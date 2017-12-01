module game.scene.Dialog;

import game.scene.SceneBase;
import game.scene.AnimationManager;
import game.player.Controler;
import sbylib;

class Dialog(dstring explainMessage) : SceneBase {

    mixin SceneBasePack;

    struct Selection {
        private Label label;
        private vec3 color;
        private Maybe!AnimationProcedure animation;

        this(dstring text, vec2 pos, vec3 color) {
            this.color = color;
            this.label = TextEntity(text, 0.2, Label.OriginX.Center, Label.OriginY.Center);
            this.label.pos = vec3(pos, 0);
            this.label.setColor(vec4(color, 1));
        }

        void selected() {
            this.animation = Just(AnimationManager().startAnimation(
                this.label.color(
                    setting(
                        this.label.getColor,
                        vec4(color, 1),
                        10,
                        Ease.linear
                    )
                )
            ));
        }

        void unselected() {
            if (this.animation.isJust) {
                this.animation.get.finish();
            }
            this.animation = Just(AnimationManager().startAnimation(
                this.label.color(
                    setting(
                        this.label.getColor,
                        vec4(color * 0.5, 1),
                        10,
                        Ease.linear
                    )
                )
            ));
        }
    }

    private Label explain;
    private Selection[2] selections;
    private uint selector;
    Entity main;

    this() {
        super();
        this.main = ColorEntity(vec4(1,1,1,0.5), 1.5, 1.5);

        this.explain = TextEntity(explainMessage, 0.3, Label.OriginX.Center, Label.OriginY.Top);
        this.explain.pos = vec3(0, 0.8, 0);
        this.main.addChild(this.explain);

        this.selections = [
            Selection("YES", vec2(-0.4, -0.2), vec3(1, 0.5, 0.5)),
            Selection("NO",  vec2(+0.4, -0.2), vec3(0.5, 0.5, 1)),
        ];

        this.selections[1].label.setColor(vec4(0.5,0.5,1,1) * 0.5);

        this.main.addChild(this.selections[0].label);
        this.main.addChild(this.selections[1].label);

        addEntity(main);

        addEvent(() => Controler().justPressed(CButton.Left), {changeSelector(-1);});
        addEvent(() => Controler().justPressed(CButton.Right), {changeSelector(+1);});
        addEvent(() => Controler().justPressed(CButton.Decide), () => this.select(this.selector));
    }

    void changeSelector(int d) {
        if (this.selector+d == -1) return;
        if (this.selector+d == this.selections.length) return;
        this.selections[this.selector].unselected();
        this.selections[this.selector+=d].selected();
    }
}
