module game.scene.Dialog;

import sbylib;

class Dialog {

    alias main this;

    private Maybe!(void delegate()) yesCallback, noCallback;

    private Label explain;
    private Entity yes, no;
    Entity main;

    this(dstring explain) {
        this.main = ColorEntity(vec4(1), 1.5, 1.5);

        this.explain = TextEntity(explain, 1, Label.OriginX.Center, Label.OriginY.Top);
        this.explain.pos = vec3(0,1,0);
        this.main.addChild(this.explain);

        this.yes = ColorEntity(vec4(1, 0.5, 0.5, 1), 0.9, 0.5);
        this.main.addChild(this.yes);

        this.no = ColorEntity(vec4(1, 0.5, 0.5, 1), 0.9, 0.5);
        this.main.addChild(this.no);
    }

    void onYes(void delegate() cb) {
        this.yesCallback = wrap(cb);
    }

    void onNo(void delegate() cb) {
        this.noCallback = wrap(cb);
    }
}
