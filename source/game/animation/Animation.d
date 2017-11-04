module game.animation.Animation;

import std.datetime.stopwatch;
import std.variant;

interface IAnimation {
    bool step();
}

interface Increaser {
    float calc(float);
}

interface PreProcess {
    float calc(float);
}

interface Ease {
    float calc(float);
}

interface PostProcess(T) {
    T calc(float);
}

class Animation(T) : IAnimation {

    private T delegate() getter;
    private void delegate(T) setter;
    private PreProcess pre;
    private PostProcess!T post;
    private Increaser inc;
    private Ease ease;
    private float count = 0;

    this(ref T val, PreProcess pre, PostProcess!T post, Increaser inc, Ease ease) {
        this.getter = () => val;
        this.setter = (T v) { val = v;};
        this.pre = pre;
        this.post = post;
        this.inc = inc;
        this.ease = ease;
    }

    override bool step() {
        this.count = inc(this.count);
        auto t = pre(this.count);
        t = ease(t);
        auto v = post(t);
        setter(v);
        if (!sw.running) sw.start();
        auto sec = sw.peek.seconds;
        auto r = sec / this.period;
        r = pre(r);
        auto v = this.ease(r);
        v = post(v);
        setter(v);
        return r <= 1;
    }
}

IAnimation NormalAnimation(T)(T start, T end, float period, Ease ease) {
    return new Animation!T(new PeriodPreProcess(period), new StartEndPostProcess!T(start, end), new SecondIncreaser, ease);
}

private class StartEndPostProcess(T) : PostProcess!T {

    private T start, end;

    this(T start, T end) {
        this.start = start;
        this.end = end;
    }

    override T calc(float v) {
        return start + (end - start) * v;
    }
}

private class PeriodPreProcess : PreProcess {

    private float seconds;

    this(float seconds) {
        this.seconds = seconds;
    }

    override float calc(float count) {
        return count / this.seconds;
    }
}

private class SecondIncreaser : Increaser {

    private StopWatch sw;

    override float calc(float count) {
        if (!sw.running) sw.start();
        return sw.peek.total!"seconds";
    }
}

Ease identity() {
    class EaseI : Ease {
        override float calc(float x) {
            return x;
        }
    }
    return new EaseI;
}

Ease quad() {
    class EaseQ : Ease {
        override float calc(float x) {
            return x * x;
        }
    }
    return new EaseQ;
}

Ease cubic() {
    class EaseC : Ease {
        override float calc(float x) {
            return x * x * x;
        }
    }
    return new EaseC;
}
