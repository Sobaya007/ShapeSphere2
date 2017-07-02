module plot.Data;

import std.datetime;
import std.string;
import std.conv;
import std.file;

class Data {

    SysTime systime;
    string srcPath;
    string name;
    long time;

    this(SysTime systime, string srcPath, string name, long time) {
        this.systime = systime;
        this.srcPath = srcPath;
        this.name = name;
        this.time = time;
    }
}
