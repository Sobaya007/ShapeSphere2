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
        procedures.filter!((AnimationProcedure proc) => !proc.done);
    }
}

class AnimationProcedure {
    private Frame frame;
    private IAnimation animation;
 
    private Maybe!(void delegate()) finishCallback = None!(void delegate());
    private bool forced;

    this(IAnimation animation) {
        this.animation = animation;
        this.frame = 0.frame;
    }

    void onFinish(void delegate() finishCallback) {
        this.finishCallback = wrap(finishCallback);
    }

    void step() {
        if (this.done) return;
        this.animation.eval(this.frame);
        this.frame++;
        if (this.done) {
            this.finishCallback.apply!(f => f());
        }
    }

    void finish() {
        this.animation.finish();
        this.finishCallback.apply!(f => f());
    }

    void forceFinish() {
        this.finishCallback.apply!(f => f());
        this.forced = true;
    }

    bool done() {
        return forced || this.animation.done;
    }
}
