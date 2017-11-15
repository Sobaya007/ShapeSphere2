module game.scene.AnimationManager;

import game.scene.SceneTransition;
import game.scene.SceneCallback;
import game.scene.SceneBase;
import sbylib;

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

    AnimationProcedure startAnimation(IAnimation anim, void delegate() onFinish = null) {
        auto proc = new AnimationProcedure(anim, onFinish);
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
    private uint frame;
    private IAnimation animation;
 
    private SceneBase scene;
    private Maybe!(void delegate()) onFinish;

    this(IAnimation animation, void delegate() onFinish) {
        this.animation = animation;
        this.frame = 0;
        this.onFinish = wrap(onFinish);
    }

    void step() {
        if (this.hasFinished) return;
        this.animation.eval(this.frame);
        this.frame++;
        if (this.hasFinished) {
            this.onFinish.apply!(f => f());
        }
    }

    void finish() {
        this.frame = this.animation.getPeriod + 1;
    }

    bool hasFinished() {
        return this.frame > this.animation.getPeriod;
    }
}
