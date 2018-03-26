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
        periods[c] = sw.peek().total!"msecs";
        total += cast(int)(periods[c] - p);
        c = (c+1)%N;
    }

    long averageTime() {
        return total / N;
    }
}
