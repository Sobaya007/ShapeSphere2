module sbylib.utils.Logger;

import std.file;
import std.datetime.stopwatch;
import std.experimental.logger;

import sbylib.utils.Path;

private FileLogger timeLogger;

class TimeLogger {

    private string name;
    private string ext;
    private StopWatch sw;

    enum TIME_LOG_PATH = GeneralPath("time.log");

    this(string name) {
        if (timeLogger is null) {

            if (exists(TIME_LOG_PATH)) remove(TIME_LOG_PATH);
            timeLogger = new FileLogger(TIME_LOG_PATH);
        }
        this.name = name;
    }

    void start(string ext = "") {
        this.ext = ext;
        sw.reset();
        sw.start();
    }

    void stop() {
        sw.stop();
        this.directWrite(this.sw.peek().total!"msecs");
    }

    void directWrite(long time) {
        timeLogger.tracef("%s%s: %d", this.name, this.ext, time);
    }
}
