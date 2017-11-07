module sbylib.animation.Animation;

import sbylib.entity.Entity;
import sbylib.math;
import sbylib.animation.Ease;

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

    T eval(uint frame) {
        return start + (end - start) * ease(cast(float)frame / period);
    }
}

interface IAnimation {
    void eval(uint);
    bool hasFinished(uint);
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

    override bool hasFinished(uint frame) {
        return frame > this.setting.period;
    }
}

IAnimation rotate(Entity entity, AnimSetting!Radian evaluator) {
    auto e = entity;
    return new Animation!Radian((rad) {
        e.rot = mat3.axisAngle(vec3(0,0,1), rad);
    }, evaluator);
}
