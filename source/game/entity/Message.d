module game.entity.Message;

import sbylib;
import game.scene.manager.AnimationManager;

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
        float arrivalWidth = text.getWidth();
        float arrivalHeight = text.getHeight();
        AnimationManager().startAnimation(
            new Animation!vec3((vec3 scale) {
                this.img.scale = scale;
            },
            setting(
                vec3(currentWidth, currentHeight,1),
                vec3(arrivalWidth, arrivalHeight, 1),
                30,
                Ease.easeInOut)));
        this.text = Just(text);

        this.entity.clearChildren();
        this.entity.addChild(text);
        this.entity.addChild(this.img);
    }

    alias entity this;
}
