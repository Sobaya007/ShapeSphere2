module sbylib.animation.Animation;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Ease;
}
import sbylib.math;
import std.algorithm;

AnimSetting!T setting(T)(T start, T end, uint period, EaseFunc ease) {
    return AnimSetting!T(start, end, period, ease);
}

struct AnimSetting(T) {

    private T start;
    private T end;
    private uint period;
    private EaseFunc ease;

    this(T start, T end, uint period, EaseFunc ease) {
        this.start = start;
        this.end = end;
        this.period = period;
        this.ease = ease;
    }

    T eval(uint frame) in {
        assert(0 <= frame && frame <= period);
    } body {
        return start + (end - start) * ease(cast(float)frame / period);
    }
}

interface IAnimation {
    void eval(uint);
    uint getPeriod();
}

class Animation(T) : IAnimation {

    alias Operator = void delegate(T);

    private Operator operator;
    private AnimSetting!T setting;

    this(Operator operator, AnimSetting!T setting) {
        this.operator = operator;
        this.setting = setting;
    }

    override void eval(uint frame) {
        operator(setting.eval(frame));
    }

    override uint getPeriod() {
        return this.setting.period;
    }
}

class MultiAnimation : IAnimation {

    private IAnimation[] animations;

    this(IAnimation[] animations) {
        this.animations = animations;
    }

    override void eval(uint frame) {
        foreach (anim; this.animations) {
            anim.eval(frame);
        }
    }

    override uint getPeriod() {
        return this.animations.map!(a => a.getPeriod).maxElement;
    }
}

class SequenceAnimation : IAnimation {
    private IAnimation[] animations;

    this(IAnimation[] animations) {
        this.animations = animations;
    }

    override void eval(uint frame) {
        foreach (anim; this.animations) {
            if (frame <= anim.getPeriod) {
                anim.eval(frame);
                return;
            } else {
                frame -= anim.getPeriod;
            }
        }
    }

    override uint getPeriod() {
        return this.animations.map!(a => a.getPeriod).sum;
    }
}

IAnimation translate(Entity entity, AnimSetting!vec2 evaluator) {
    auto e = entity;
    return new Animation!vec2((vec2 tr) {
        e.pos = vec3(tr, 0);
    }, evaluator);
}

IAnimation rotate(Entity entity, AnimSetting!Radian evaluator) {
    auto e = entity;
    return new Animation!Radian((Radian rad) {
        e.rot = mat3.axisAngle(vec3(0,0,1), rad);
    }, evaluator);
}

IAnimation multi(IAnimation[] animations) {
    return new MultiAnimation(animations);
}

IAnimation sequence(IAnimation[] animations) {
    return new SequenceAnimation(animations);
}
