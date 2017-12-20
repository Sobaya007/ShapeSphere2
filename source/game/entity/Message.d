module game.entity.Message;

import sbylib;
import game.scene.manager.AnimationManager;
import std.algorithm;

class Message {

    Entity entity;

    private Maybe!Label text;
    private Entity img;

    this(dstring message) {
        this.entity = new Entity();
        this.img = ImageEntity(ImagePath("message.png"), 1, 1);
        this.setMessage(message);
    }

    void setMessage(dstring message) {
        float currentWidth = this.text.getWidth().getOrElse(0);
        float currentHeight = this.text.getHeight().getOrElse(0);
        auto text = TextEntity(message, 0.2, Label.OriginX.Left, Label.OriginY.Top);
        text.setWrapWidth(1);
        text.pos = vec3(-text.getWidth()/2, text.getHeight()/2, 0.5);
        text.letters.each!((Letter letter) => letter.getEntity().getMesh.mat.config.visible = false);
        float arrivalWidth = text.getWidth();
        float arrivalHeight = text.getHeight();
        AnimationManager().startAnimation(
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
                        text.letters[cast(int)time].getEntity.getMesh.mat.config.visible = true;
                    },
                    setting(
                        0f,
                        cast(float)(text.letters.length-1),
                        cast(uint)(10 * text.letters.length),
                        Ease.linear
                    )
                )
            ])
        );
        this.text = Just(text);

        this.entity.clearChildren();
        this.entity.addChild(text);
        this.entity.addChild(this.img);
    }

    alias entity this;
}
