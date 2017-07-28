import std.getopt;
import Run;

extern(C) __gshared string[] rt_options = ["gcopt=profile:1"];

void main(string[] args) {
    RunMode runMode;
    auto po = getopt(args, std.getopt.config.passThrough, "mode", &runMode);

    if (po.helpWanted) {
        showHelp();
    } else {
        run(runMode, args);
    }
}

