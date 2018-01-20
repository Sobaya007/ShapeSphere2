module game.entity.Message;

import sbylib;
import game.Game;
import game.player.Controller;
import game.command;
import std.algorithm;

class Message : CommandReceiver {

    Entity entity;

    private Maybe!Label text;
    private Entity img;
    private void delegate() onFinish;
    private Maybe!AnimationProcedure procedure;

    this() {
        this.entity = new Entity();
        this.img = ImageEntity(ImagePath("message.png"), 1, 1);

        this.addCommand(new ButtonCommand(() => Controller().justPressed(CButton.Decide), &this.onDecisideJustPressed));
    }

    void setMessage(dstring message, void delegate() onFinish) {
        this.onFinish = onFinish;
        this.setMessage(message);
    }

    void setMessage(dstring message) in {
        assert(this.procedure.hasFinished.getOrElse(true));
    } body {
        float currentWidth = this.text.getWidth().getOrElse(0);
        float currentHeight = this.text.getHeight().getOrElse(0);
        auto text = TextEntity(message, 0.1, Label.OriginX.Left, Label.OriginY.Top);
        text.setWrapWidth(1);
        text.pos = vec3(-text.getWidth()/2, text.getHeight()/2, 0.5);
        text.letters.each!((Letter letter) => letter.getEntity().visible = false);
        float arrivalWidth = text.getWidth();
        float arrivalHeight = text.getHeight();
        this.img.scale = vec3(0);
        this.procedure = Just(AnimationManager().startAnimation(
            sequence(cast(IAnimation[])[
                new Animation!vec3(
                    (vec3 scale) {
                        this.img.scale = scale * 1.1;
                    },
                    setting(
                        vec3(currentWidth, currentHeight,1),
                        vec3(arrivalWidth, arrivalHeight, 1),
                        30,
                        Ease.easeInOut
                    )
                ),
                new Animation!float(
                    (float time) {
                        text.letters[cast(int)time].getEntity.visible = true;
                    },
                    setting(
                        0f,
                        cast(float)(text.letters.length-1),
                        cast(uint)(5 * text.letters.length),
                        Ease.linear
                    )
                )
            ])
        ));
        this.text.destroy();
        this.text = Just(text);

        this.entity.clearChildren();
        this.entity.addChild(text);
        this.entity.addChild(this.img);
    }

    private void onDecisideJustPressed() {
        if (!this.procedure.get().hasFinished) return;
        this.setMessage("");
        this.procedure.onFinish({
            this.entity.remove();
            this.onFinish();
        });
    }

    alias entity this;
}
