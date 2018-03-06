module game.entity.Message;

import sbylib;
import game.Game;
import game.player.Controller;
import game.command;
import std.algorithm;

class Message : CommandReceiver {

    Entity entity;

    private Label text;
    private Entity img;
    private void delegate() onFinish;
    private Maybe!AnimationProcedure procedure;

    this() {

        LabelFactory factory;
        factory.height = 0.1;
        factory.strategy = Label.Strategy.Center;
        factory.wrapWidth = 1;
        this.text = factory.make();
        text.pos.z = -0.5;

        this.img = makeImageEntity(ImagePath("message.png"), 1, 1);

        this.entity = new Entity();
        this.entity.addChild(text);
        this.entity.addChild(img);

        this.addCommand(new ButtonCommand(() => Controller().justPressed(CButton.Decide), &this.onDecisideJustPressed));
    }

    void setMessage(dstring message, void delegate() onFinish) {
        this.onFinish = onFinish;
        this.setMessage(message);
    }

    void setMessage(dstring message) in {
        assert(this.procedure.hasFinished.getOrElse(true));
    } body {
        float currentWidth = this.text.getWidth();
        float currentHeight = this.text.getHeight();
        text.renderText(message);
        text.traverse!((Entity e) => e.visible = false);
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
                        text.renderText(message[0..cast(int)time]);
                    },
                    setting(
                        0f,
                        message.length + 0.5f,
                        cast(uint)(5 * message.length),
                        Ease.linear
                    )
                )
            ])
        ));
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
