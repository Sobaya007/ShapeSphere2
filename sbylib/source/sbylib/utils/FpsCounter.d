module sbylib.utils.FpsCounter;

import sbylib;
import std.datetime.stopwatch;

class FpsCounter(uint N) {
    private TimeCounter!N timeCounter;

    this() {
        this.timeCounter = new TimeCounter!N;
    }

    void update() {
        timeCounter.stop();
        timeCounter.start();
    }

    long getFPS() {
        return 1000 / timeCounter.averageTime;
    }
}
