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
        return [encode(v.x), encode(v.y)];
    }

    override void act() {
        // for making result same as replay, once encode
        auto s = this.state();
        auto d = vec2(decode(encode(s.x)), decode(encode(s.y)));
        this.action(d);
    }

    override void replay(ref ubyte[] v) {
        this.action(vec2(decode(v[0]), decode(v[1])));
        v = v[2..$];
    }

    private static ubyte encode(float v) in {
        assert(-1 <= v && v <= 1);
    } body {
        auto tmp = (v + 1) / 2 * 255;
        assert(ubyte.min <= tmp && tmp <= ubyte.max);
        return cast(ubyte)(tmp);
    }

    private static float decode(ubyte v) out(res) {
        assert(-1 <= res && res <= 1);
    } body {
        if (v == 127) return 0; //これしないと入力がないときもきちゃう
        return (cast(float)v) / 255 * 2 - 1;
    }

    unittest {
        assert(encode(1) == 255);
        assert(encode(0) == 127);
        assert(encode(-1) == 0);
        assert(decode(255) == 1);
        assert(decode(0) == -1);
    }
}
