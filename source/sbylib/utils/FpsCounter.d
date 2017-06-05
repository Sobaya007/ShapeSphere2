module sbylib.utils.FpsCounter;

import sbylib;

class FpsCounter(uint N) {
    long[N] periods;

    int total;
    StopWatch sw;
    int c;

    this() {
        sw.start();
    }

    void update() {
        auto p = periods[c];
        periods[c] = sw.peek().msecs();
        total += cast(int)(periods[c] - p);
        c = (c+1)%N;
        sw.reset();
    }

    long getFPS() {
        if (total == 0) return 0;
        return 1000 * N / total;
    }
}
