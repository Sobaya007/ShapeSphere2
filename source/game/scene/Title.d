module game.scene.Title;

import std.algorithm, std.array;
import game.scene.SceneBase;
import game.scene.SceneTransition;
import game.scene.AnimationManager;
import game.player.Controler;
import sbylib;

class Title : SceneBase {

    mixin SceneBasePack;

    private Label[] selections;
    private uint selector;

    this() {
        auto text = TextEntity("タイトル"d, 0.4);
        auto newGame = TextEntity("New Game", 0.2, Label.OriginX.Right, Label.OriginY.Center);
        auto loadGame = TextEntity("Load Game", 0.2, Label.OriginX.Right, Label.OriginY.Center);
        newGame.pos.xy = vec2(1,-0.3);
        loadGame.pos.xy = vec2(0.9,-0.5);
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
                    s.color(
                        setting(
                            vec4(0),
                            vec4(0.5),
                            60,
                            Ease.linear
                        )
                    )).array
                )
            ])
        );
        addEntity(text);
        foreach (s; this.selections) {
            addEntity(s);
        }
    }

    override void step() {
        if (Controler().justPressed(CButton.Up)) {
            this.changeSelector(-1);
        }
        if (Controler().justPressed(CButton.Down)) {
            this.changeSelector(+1);
        }
        super.step();
    }

    void changeSelector(int d) {
        if (this.selector == 0) return;
        if (this.selector == this.selections.length-1) return;
        this.selector += d;
    }
}
