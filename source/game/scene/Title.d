module game.scene.Title;

import std.algorithm, std.array;
import game.scene.SceneBase;
import game.player.Controller;
import game.scene.Dialog;
import sbylib;

class Title : SceneProtoType {

    mixin SceneBasePack;

    private Label text;
    private Selection[] selections;
    private uint selector = 0;

    this() {
        this.text = makeTextEntity("Shape Sphere"d, 0.3);
        auto newGame = Selection("New Game"d, vec2(0.5, -0.6));
        auto loadGame = Selection("Load Game"d, vec2(0.45, -0.75));
        selections = [newGame, loadGame];
        super();
        addEntity(text);
        foreach (s; this.selections) {
            addEntity(s.label);
        }
    }

    override void initialize() {
        AnimationManager().startAnimation(
            sequence(
                fade(
                    setting(
                        vec4(0,0,0,1),
                        vec4(0,0,0,0),
                        60.frame,
                        Ease.Linear
                    )
                ),
                multi(
                    selections.map!(s =>
                        s.label.colorAnimation(
                            setting(
                                vec4(0),
                                vec4(0.5),
                                60.frame,
                                Ease.Linear
                            )
                        )
                    ).array
                ),
                multi(
                    this.selections[0].label.translate(
                        setting(
                            this.selections[0].label.pos.xy,
                            this.selections[0].basePos - vec2(0.05,0),
                            10.frame,
                            Ease.InOut
                        )
                    ),
                    this.selections[0].label.colorAnimation(
                        setting(
                            vec4(0.5),
                            vec4(1),
                            10.frame,
                            Ease.Linear
                        )
                    )
                )
            )
        ).onFinish({
            addEvent(() => Controller().justPressed(CButton.Up), {
                this.changeSelector(-1);
            });
            addEvent(() => Controller().justPressed(CButton.Down), {
                this.changeSelector(+1);
            });
            addEvent(() => Controller().justPressed(CButton.Decide), {
                this.select(this.selector);
            });
        });
    }

    void changeSelector(int d) {
        if (this.selector+d == -1) return;
        if (this.selector+d == this.selections.length) return;
        this.selections[this.selector].unselect();
        this.selections[this.selector+=d].select();
    }

    struct Selection {
        private Label label;
        private vec2 basePos;
        private Maybe!AnimationProcedure animation;
        this(dstring text, vec2 basePos) {
            LabelFactory factory;
            factory.text = text;
            factory.height = 0.15;
            factory.strategy = Label.Strategy.Right;
            factory.textColor = vec4(0);
            this.label = factory.make();
            this.basePos = basePos;
            this.label.pos.x = basePos.x;
            this.label.pos.y = basePos.y;
        }

        void select() {
            this.animation = Just(AnimationManager().startAnimation(
                multi(
                    this.label.translate(
                        setting(
                            this.label.pos.xy,
                            basePos - vec2(0.05,0),
                            10.frame,
                            Ease.InOut
                        )
                    ),
                    this.label.colorAnimation(
                        setting(
                            this.label.color,
                            vec4(1),
                            10.frame,
                            Ease.Linear
                        )
                    )
                )
            ));
        }

        void unselect() {
            if (this.animation.isJust) {
                this.animation.unwrap().finish();
            }
            this.animation = Just(AnimationManager().startAnimation(
                multi(
                    this.label.translate(
                        setting(
                            this.label.pos.xy,
                            basePos,
                            10.frame,
                            Ease.InOut
                        )
                    ),
                    this.label.colorAnimation(
                        setting(
                            this.label.color,
                            vec4(0.5),
                            10.frame,
                            Ease.Linear
                        )
                    )
                )
            ));
        }
    }
}
