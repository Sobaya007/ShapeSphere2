module sbylib.utils.TimeCounter;

import sbylib;
import std.datetime.stopwatch;

class TimeCounter(uint N) {
    long[N] periods;

    int total;
    StopWatch sw;
    int c;

    this() {
        sw.start();
    }

    void start() {
        sw.reset();
    }

    void stop() {
        auto p = periods[c];
        periods[c] = sw.peek().total!"usecs";
        total += cast(int)(periods[c] - p);
        c = (c+1)%N;
    }

    float averageTime() {
        return total / N * 1e-3;
    }
}
