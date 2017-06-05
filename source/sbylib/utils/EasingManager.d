module sbylib.utils.EasingManager;

import std.algorithm;
import std.functional;

class EasingManager(T) {
    private {
        int _duration;
        T _start;
        T _end;
        float delegate(float t) _func;

        int _nowTime;
    }

    package this(float delegate(float t) func) {
        _nowTime = 0;
        _duration = -1;
        _func = func;
    }

    void set(T start, T end, int duration) {
        _start = start;
        _end = end;
        _duration = duration;
        _nowTime = 0;
    }

    T get() in {
        assert(!done, "終了したEasingの値を取得はできない");
    } body {
        return (_nowTime / cast(float)_duration).pipe!(
                t => _func( max(0.0, min(1.0, t)) ),
                x => _start*(1-x) + _end*x
        );
    }

    void step() {
        _nowTime++;
    }

    bool done() @property {
        return _nowTime > _duration;
    }

    override string toString() {
        import std.conv;
        string res = "EasingManager: ";
        res ~= "{duration: " ~ _duration.to!string;
        res ~= ", start: " ~ _start.to!string;
        res ~= ", end: " ~ _end.to!string;
        res ~= ", nowTime: " ~ _nowTime.to!string;
        return res ~= "}";
    }
}
