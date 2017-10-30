module sbylib.utils.FpsBalancer;

import sbylib;
import std.datetime.stopwatch;
import std.stdio;
import core.thread;

class FpsBalancer {
    private StopWatch sw;
    private const long frameTime;
    private Duration before;

    this(float fps) {
        this.frameTime = cast(long)(1000 / fps);
    }

    void loop(bool delegate() func) {
        sw.start();
        before = sw.peek;
        while (true) {
            if (func()) break;
            auto current = sw.peek;
            auto period = current - before;
            if (this.frameTime.msecs > period) {
                Thread.sleep(this.frameTime.msecs - period);
            }
            before = current;
        }
    }
}
