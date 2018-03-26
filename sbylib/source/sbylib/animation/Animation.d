module sbylib.animation.Animation;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Ease;
    import sbylib.utils.Unit : Frame, frame;
}
import sbylib.math;
import std.algorithm;

AnimSetting!T setting(T)(T start, T end, Frame period, EaseFunc ease) {
    return AnimSetting!T(start, end, period, ease);
}

struct AnimSetting(T) {

    private T start;
    private T end;
    private Frame period;
    private EaseFunc ease;

    this(T start, T end, Frame period, EaseFunc ease) {
        this.start = start;
        this.end = end;
        this.period = period;
        this.ease = ease;
    }

    T eval(Frame frame) in {
        assert(0 <= frame && frame <= period);
    } body {
        return start + (end - start) * ease(cast(float)frame / period);
    }
}

interface IAnimation {
    void eval(Frame);
    bool done();
    void finish() out { assert(done); }
}

interface IAnimationWithPeriod : IAnimation {
    Frame period();
}

class Animation(T) : IAnimationWithPeriod {

    alias Operator = void delegate(T);

    private Operator operator;
    private AnimSetting!T setting;
    private Frame lastFrame;

    this(Operator operator, AnimSetting!T setting) {
        this.operator = operator;
        this.setting = setting;
    }

    override void eval(Frame frame) {
        operator(setting.eval(frame));
        this.lastFrame = frame;
    }

    override Frame period() {
        return this.setting.period;
    }

    override bool done() {
        return this.period <= this.lastFrame;
    }

    override void finish() {
        this.eval(this.period);
        this.lastFrame++;
    }
}

class ManualAnimation : IAnimationWithPeriod {

    alias Kill = void delegate();
    alias Operator = void delegate(Kill);

    private Operator operator;
    private bool autoStep;
    private bool isDone;
    private Maybe!(Frame) resultedPeriod;

    this(Operator operator, bool autoStep) {
        this.operator = operator;
        this.autoStep = autoStep;
        this.resultedPeriod = None!Frame;
    }

    override void eval(Frame frame) {
        if (operator) {
            operator(&kill);
            if (!autoStep) operator = null;
        }
        if (this.resultedPeriod.isNone && done) {
            this.resultedPeriod = Just(frame);
        }
    }

    override bool done() {
        return this.isDone;
    }

    override Frame period() {
        return resultedPeriod.getOrElse(long.max.frame);
    }

    override void finish() {
        this.isDone = true;
    }

    private void kill() {
        this.isDone = true;
    }
}

class SingleAnimation : IAnimationWithPeriod {

    alias Operator = void delegate();

    Operator operator;

    this(Operator operator) {
        this.operator = operator;
    }

    override void eval(Frame frame) {
        if (this.operator is null) return;
        this.operator();
        this.operator = null;
    }

    override bool done() {
        return operator !is null;
    }

    override Frame period() {
        return 1.frame;
    }

    override void finish() {
    }
}

class WaitAnimation : IAnimationWithPeriod {

    private Frame _period;
    private Frame lastFrame;

    this(Frame period) {
        this._period = period;
    }

    override void eval(Frame frame) {
        this.lastFrame = frame;
    }

    override bool done() {
        return period <= lastFrame;
    }

    override Frame period() {
        return _period;
    }

    override void finish() {
        this.eval(period);
        this.lastFrame++;
    }
}

class MultiAnimation(Base) : Base {

    private Base[] animations;

    this(Base[] animations) {
        this.animations = animations;
    }

    override void eval(Frame frame) {
        foreach (anim; this.animations.filter!(a => !a.done)) {
            anim.eval(frame);
        }
    }

    override bool done() {
        return this.animations.all!(a => a.done);
    }

    static if (is(Base == IAnimationWithPeriod)) {
        override Frame period() {
            return this.animations.map!(a => a.period).maxElement;
        }
    }

    override void finish() {
        this.animations.filter!(a => !a.done).each!(a => a.finish());
    }
}

class SequenceAnimation : IAnimationWithPeriod {
    private IAnimationWithPeriod[] animations;

    this(IAnimationWithPeriod[] animations) {
        this.animations = animations;
    }

    override void eval(Frame frame) {
        foreach (anim; this.animations) {
            if (frame <= anim.period) {
                anim.eval(frame);
                return;
            } else {
                frame -= anim.period;
            }
        }
    }

    override Frame period() {
        return this.animations.map!(a => a.period).sum;
    }

    override bool done() {
        return this.animations.all!(a => a.done);
    }

    override void finish() {
        this.animations.filter!(a => !a.done).each!(a => a.finish());
    }
}

auto animation(T)(void delegate(T) operator, AnimSetting!T setting) {
    return new Animation!T(operator, setting);
}

auto animation(void delegate(void delegate()) operator, bool autoStep) {
    return new ManualAnimation(operator, autoStep);
}

auto translate(Entity entity, AnimSetting!vec2 evaluator) {
    auto e = entity;
    return animation((vec2 tr) => e.pos = vec3(tr, 0), evaluator);
}

auto rotate(Entity entity, AnimSetting!Radian evaluator) {
    auto e = entity;
    return animation((Radian rad) => e.rot = mat3.axisAngle(vec3(0,0,1), rad), evaluator);
}

auto multi(Animations...)(Animations animations) {
    import std.traits, std.meta;
    template TypeOf(T) {
        static if (isArray!(T)) {
            alias TypeOf = ForeachType!(T);
        } else {
            alias TypeOf = T;
        }
    }
    static if (allSatisfy!(ApplyLeft!(isAssignable, IAnimationWithPeriod), staticMap!(TypeOf, Animations))) {
        alias BaseType = IAnimationWithPeriod;
    } else {
        alias BaseType = IAnimation;
    }
    BaseType[] args;
    static foreach (a; animations) {
        static if (isArray!(typeof(a))) {
            foreach (x; a) args ~= x;
        } else {
            args ~= a;
        }

    }
    return new MultiAnimation!(BaseType)(args);
}

auto sequence(Animations...)(Animations animations) {
    IAnimationWithPeriod[] args;
    foreach (a; animations) {
        args ~= a;
    }
    return new SequenceAnimation(args);
}

auto wait(Frame period) {
    return new WaitAnimation(period);
}

auto single(void delegate() event) {
    return new SingleAnimation(event);
}
