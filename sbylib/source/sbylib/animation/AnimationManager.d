module sbylib.animation.AnimationManager;

import sbylib.animation.Animation;
import sbylib.utils.Array;
import sbylib.utils.Maybe;

class AnimationManager {
    private static AnimationManager instance;
    public static AnimationManager opCall() {
        if (instance is null) {
            return instance = new AnimationManager();
        }
        return instance;
    }
    private Array!AnimationProcedure procedures;

    this() {
        this.procedures = Array!AnimationProcedure(0);
    }

    AnimationProcedure startAnimation(IAnimation anim) {
        auto proc = new AnimationProcedure(anim);
        this.procedures ~= proc;
        return proc;
    }

    void step() {
        foreach (proc; procedures) {
            proc.step();
        }
        procedures.filter!((AnimationProcedure proc) => !proc.hasFinished);
    }
}

class AnimationProcedure {
    private Frame frame;
    private IAnimation animation;
 
    private Maybe!(void delegate()) finishCallback = None!(void delegate());

    this(IAnimation animation) {
        this.animation = animation;
        this.frame = 0.frame;
    }

    void onFinish(void delegate() finishCallback) {
        this.finishCallback = wrap(finishCallback);
    }

    void step() {
        if (this.hasFinished) return;
        this.animation.eval(this.frame);
        this.frame++;
        if (this.hasFinished) {
            this.finishCallback.apply!(f => f());
        }
    }

    deprecated void finish() {
        //this.frame = this.animation.getPeriod + 1;
    }

    bool hasFinished() {
        return this.animation.done;
    }
}
