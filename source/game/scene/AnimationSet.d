module game.scene.AnimationSet;

import game.scene.SceneTransition;
import game.scene.SceneCallback;
import game.scene.SceneBase;
import sbylib;

interface AnimationSet {
    void initialize();
    void setScene(SceneBase);
    Maybe!SceneTransition step();
}

class ThroughAnimationSet : AnimationSet {
    private uint frame;
    private Maybe!size_t idx;
    private IAnimation[] animations;
 
    private SceneBase scene;

    this(IAnimation[] animations) {
        this.animations = animations;
    }

    override void setScene(SceneBase scene) {
        this.scene = scene;
    }

    override void initialize() {
        this.frame = 0;
        this.idx = this.getAnimationIndex(0);
    }

    override Maybe!SceneTransition step() {
        if (this.idx.isNone) return Just(scene.finish());
        auto anim = this.animations[this.idx.get];
        anim.eval(this.frame);
        this.frame++;
        if (anim.hasFinished(this.frame)) {
            this.idx = this.getAnimationIndex(this.idx.get + 1);
            this.frame = 0;
        }
        return None!SceneTransition;
    }

    private Maybe!size_t getAnimationIndex(size_t idx) {
        return idx < this.animations.length ? Just(idx) : None!size_t;
    }
}

class LoopAnimationSet : AnimationSet {
    private uint frame;
    private Maybe!size_t idx;
    private IAnimation[] animations;
    private SceneBase scene;

    this(IAnimation[] animations) {
        this.animations = animations;
    }

    override void setScene(SceneBase scene) {
        this.scene = scene;
    }

    override void initialize() {
        this.frame = 0;
        this.idx = this.getAnimationIndex(0);
    }

    override Maybe!SceneTransition step() {
        if (this.idx.isNone) {
            this.initialize();
            return None!SceneTransition;
        }
        auto anim = this.animations[this.idx.get];
        anim.eval(this.frame);
        this.frame++;
        if (anim.hasFinished(this.frame)) {
            this.idx = this.getAnimationIndex(this.idx.get);
            this.frame = 0;
        }
        return None!SceneTransition;
    }

    private Maybe!size_t getAnimationIndex(size_t idx) {
        return idx < this.animations.length ? Just(idx) : None!size_t;
    }
}

class WaitAnimationSet : AnimationSet {
    private uint frame;
    private Maybe!size_t idx;
    private IAnimation[] animations;
    private SceneBase scene;

    this(IAnimation[] animations) {
        this.animations = animations;
    }

    override void setScene(SceneBase scene) {
        this.scene = scene;
    }

    override void initialize() {
        this.frame = 0;
        this.idx = this.getAnimationIndex(0);
    }

    override Maybe!SceneTransition step() {
        if (this.idx.isNone) return None!SceneTransition;
        auto anim = this.animations[this.idx.get];
        anim.eval(this.frame);
        this.frame++;
        if (anim.hasFinished(this.frame)) {
            this.idx = this.getAnimationIndex(this.idx.get);
            this.frame = 0;
        }
        return None!SceneTransition;
    }

    private Maybe!size_t getAnimationIndex(size_t idx) {
        return idx < this.animations.length ? Just(idx) : None!size_t;
    }
}
