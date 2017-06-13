module sbylib.utils.FpsBalancer;

import sbylib;
import std.datetime;
import std.stdio;
import core.thread;

class FpsBalancer {
    private StopWatch sw;
    private const long frameTime;

    this(float fps) {
        this.frameTime = cast(long)(1000 / fps);
    }

    void loop(bool delegate() func) {
        sw.start();
        while (true) {
            if (func()) break;
            auto period = sw.peek.msecs;
            if (this.frameTime > period) {
                Thread.sleep(dur!("msecs")(this.frameTime - period));
            }
            sw.start();
            //stdout.flush();
        }
    }
}
