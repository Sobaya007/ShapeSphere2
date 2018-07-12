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
        this.text.pos.z = 0.5;

        ImageEntityFactory imageFactory;
        imageFactory.width = 1;
        imageFactory.height = 1;
        this.img = imageFactory.make(ImagePath("message.png"));

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
        assert(this.procedure.done.getOrElse(true));
    } body {
        float currentWidth = this.text.width;
        float currentHeight = this.text.height;
        text.renderText(message);
        float arrivalWidth = text.width;
        float arrivalHeight = text.height;
        text.renderText("");
        this.img.scale = vec3(0);
        this.procedure = Just(AnimationManager().startAnimation(
            sequence(
                animation(
                    (vec3 scale) {
                        this.img.scale = scale * 1.1;
                    },
                    setting(
                        vec3(currentWidth, currentHeight,1),
                        vec3(arrivalWidth, arrivalHeight, 1),
                        30.frame,
                        &Ease.easeInOut
                    )
                ),
                animation(
                    (float time) {
                        text.renderText(message[0..cast(int)time]);
                    },
                    setting(
                        0f,
                        message.length + 0.5f,
                        (5 * message.length).frame,
                        &Ease.linear
                    )
                )
            )
        ));
    }

    private void onDecisideJustPressed() {
        if (!this.procedure.unwrap().done) return;
        this.setMessage("");
        this.procedure.onFinish({
            this.entity.remove();
            this.onFinish();
        });
    }

    alias entity this;
}
