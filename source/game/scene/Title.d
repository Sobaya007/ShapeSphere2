module game.scene.Title;

import std.algorithm, std.array;
import game.scene.SceneBase;
import game.scene.SceneTransition;
import game.scene.AnimationManager;
import game.player.Controler;
import game.scene.Dialog;
import sbylib;

class Title : SceneBase {

    mixin SceneBasePack;

    private Selection[] selections;
    private uint selector;

    struct Selection {
        private Label label;
        private vec2 basePos;
        private Maybe!AnimationProcedure animation;
        this(dstring text, vec2 basePos) {
            this.label = TextEntity(text, 0.15, Label.OriginX.Right, Label.OriginY.Center);
            this.basePos = basePos;
            this.label.pos = vec3(basePos, 0);
            this.label.setColor(vec4(0));
        }

        void selected() {
            this.animation = Just(AnimationManager().startAnimation(
                multi([
                    this.label.translate(
                        setting(
                            this.label.pos.xy,
                            basePos - vec2(0.05,0),
                            10,
                            Ease.easeInOut
                        )
                    ),
                    this.label.color(
                        setting(
                            this.label.getColor,
                            vec4(1),
                            10,
                            Ease.linear
                        )
                    )
                ])
            ));
        }

        void unselected() {
            if (this.animation.isJust) {
                this.animation.get.finish();
            }
            this.animation = Just(AnimationManager().startAnimation(
                multi([
                    this.label.translate(
                        setting(
                            this.label.pos.xy,
                            basePos,
                            10,
                            Ease.easeInOut
                        )
                    ),
                    this.label.color(
                        setting(
                            this.label.getColor,
                            vec4(0.5),
                            10,
                            Ease.linear
                        )
                    )
                ])
            ));
        }
    }

    this() {
        auto text = TextEntity("タイトル"d, 0.4);
        auto newGame = Selection("New Game"d, vec2(0.9, -0.6));
        auto loadGame = Selection("Load Game"d, vec2(0.85, -0.75));
        selections = [newGame, loadGame];
        super();
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
                text.rotate(
                    setting(
                        Radian(0.deg),
                        Radian(360.deg),
                        60,
                        Ease.linear
                    )
                ),
                multi(selections.map!(s =>
                    s.label.color(
                        setting(
                            vec4(0),
                            vec4(0.5),
                            60,
                            Ease.linear
                        )
                    )).array
                ),
                multi([
                    this.selections[0].label.translate(
                        setting(
                            this.selections[0].label.pos.xy,
                            this.selections[0].basePos - vec2(0.05,0),
                            10,
                            Ease.easeInOut
                        )
                    ),
                    this.selections[0].label.color(
                        setting(
                            vec4(0.5),
                            vec4(1),
                            10,
                            Ease.linear
                        )
                    )
                ])
            ])
        ).onFinish({
            addEvent(() => Controler().justPressed(CButton.Up), {
                this.changeSelector(-1);
            });
            addEvent(() => Controler().justPressed(CButton.Down), {
                this.changeSelector(+1);
            });
            addEvent(() => Controler().justPressed(CButton.Decide), {
                pushEvents();
            });
        });
        addEntity(text);
        foreach (s; this.selections) {
            addEntity(s.label);
        }
        /*
        */
        addEntity(new Dialog("po"));
    }

    void changeSelector(int d) {
        if (this.selector+d == -1) return;
        if (this.selector+d == this.selections.length) return;
        this.selections[this.selector].unselected();
        this.selections[this.selector+=d].selected();
    }
}
