module sbylib.utils.Logger;

import std.file;
import std.datetime;
import std.experimental.logger;
import sbylib.setting;

private FileLogger timeLogger;

class TimeLogger {

    private string name;
    private string ext;
    private StopWatch sw;

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
        this.directWrite(this.sw.peek().msecs);
    }

    void directWrite(long time) {
        if (runMode == RunMode.Game) {
            timeLogger.tracef("%s%s: %d", this.name, this.ext, time);
        }
    }
}
