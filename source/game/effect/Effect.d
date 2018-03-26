module game.effect.Effect;

import sbylib;

interface Effect {
    void step();
    bool done();
}


class EffectManager {

    mixin Singleton;

    Array!(Effect) effectList;

    private this() {
        Core().addProcess(&step, "Effect Manager");
        effectList = Array!(Effect)(0);
    }

    void start(Effect effect) {
        effectList ~= effect;
    }

    void step() {
        this.effectList.filter!((Effect e) {
            e.step();
            return !e.done;
        });
    }
}
