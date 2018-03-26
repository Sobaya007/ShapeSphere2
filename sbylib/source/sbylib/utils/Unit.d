module sbylib.utils.Unit;

import std.typecons;

struct Frame {
    long f;
    alias f this;

    Frame opBinary(string op)(Frame frame) {
        return Frame(mixin("this.f "~op~" frame.f"));
    }
}
Frame frame(long f) { return Frame(f);}
