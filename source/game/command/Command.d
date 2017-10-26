module game.command.Command;

import std.algorithm, std.range;
import sbylib;

interface ICommand {
    ubyte[] value();
    void act();
    void replay(ref ubyte[]);
}

class ButtonCommand : ICommand {
    private bool delegate() cond;
    private void delegate() action;

    this(bool delegate() cond, void delegate() action) {
        this.cond = cond;
        this.action = action;
    }

    override ubyte[] value() {
        return cond() ? [1] : [0];
    }

    override void act() {
        if (cond()) this.action();
    }

    override void replay(ref ubyte[] v) {
        assert(v[0] == 0 || v[0] == 1);
        if (v[0] == 1) {
            this.action();
        }
        v = v[1..$];
    }
}

class StickCommand : ICommand {
    private vec2 delegate() state;
    private void delegate(vec2) action;

    this(vec2 delegate() state, void delegate(vec2) action) {
        this.state = state;
        this.action = action;
    }

    override ubyte[] value() {
        auto v = state();
        return [this.encode(v.x), this.encode(v.y)];
    }

    override void act() {
        this.action(this.state());
    }

    override void replay(ref ubyte[] v) {
        this.action(vec2(this.decode(v[0]), this.decode(v[1])));
        v = v[2..$];
    }

    private ubyte encode(float v) in {
        assert(-1 <= v && v <= 1);
    } body {
        auto tmp = (v + 1) / 2 * 255;
        assert(ubyte.min <= tmp && tmp <= ubyte.max);
        return cast(ubyte)(tmp);
    }

    private float decode(ubyte v) out(res) {
        assert(-1 <= res && res <= 1);
    } body {
        return (cast(float)v) / 255 * 2 - 1;
    }
}
