module game.scene.Dialog;

import game.scene.SceneBase;
import game.player.Controller;
import sbylib;

class Dialog(dstring explainMessage) : SceneProtoType {

    mixin SceneBasePack;

    private Label explain;
    private Selection[2] selections;
    private bool hasSelectorMoved;
    private uint selector;
    Entity main;

    this() {
        super();
        this.main = makeColorEntity(vec4(1,1,1,0.5), 1.5, 1.5);

        this.explain = makeTextEntity(explainMessage,0.3);
        this.explain.top = 0.8;
        this.main.addChild(this.explain);

        this.selections = [
            Selection("YES", vec2(-0.4, -0.2), vec3(1, 0.5, 0.5)),
            Selection("NO",  vec2(+0.4, -0.2), vec3(0.5, 0.5, 1)),
        ];

        this.main.addChild(this.selections[0].label);
        this.main.addChild(this.selections[1].label);

        addEntity(main);

        addEvent(() => Controller().justPressed(CButton.Left), {changeSelector(-1);});
        addEvent(() => Controller().justPressed(CButton.Right), {changeSelector(+1);});
        addEvent(() => Controller().justPressed(CButton.Decide), {
            if (!this.hasSelectorMoved) return;
            this.select(this.selector);
        });
    }

    override void initialize() {
        this.hasSelectorMoved = false;
        this.selector = 0;

        this.selections[0].label.color = vec4(1,0.5,0.5,1) * 0.5;
        this.selections[1].label.color = vec4(0.5,0.5,1,1) * 0.5;
    }

    void changeSelector(int d) {
        if (hasSelectorMoved) {
            this.selections[this.selector].unselect();
        }
        this.selector += d;
        if (this.selector == -1) this.selector = 0;
        if (this.selector == this.selections.length) this.selector = this.selections.length-1;
        this.selections[this.selector].select();
        this.hasSelectorMoved = true;
    }

    struct Selection {
        private Label label;
        private vec3 color;
        private Maybe!AnimationProcedure animation;

        this(dstring text, vec2 pos, vec3 color) {
            this.color = color;
            this.label = makeTextEntity(text, 0.2);
            this.label.pos = vec3(pos, 0);
            this.label.color = vec4(color, 1);
        }

        void select() {
            this.animation = Just(AnimationManager().startAnimation(
                this.label.colorAnimation(
                    setting(
                        this.label.color,
                        vec4(color, 1),
                        10.frame,
                        &Ease.linear
                    )
                )
            ));
        }

        void unselect() {
            if (this.animation.isJust) {
                this.animation.get.finish();
            }
            this.animation = Just(AnimationManager().startAnimation(
                this.label.colorAnimation(
                    setting(
                        this.label.color,
                        vec4(color * 0.5, 1),
                        10.frame,
                        &Ease.linear
                    )
                )
            ));
        }
    }
}
