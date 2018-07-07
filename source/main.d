import std.getopt;
import entry;

extern(C) __gshared string[] rt_options = ["gcopt=profile:1"];

void main(string[] args) {
    import sbylib;
    Maybe!RunMode runMode;
    auto po = getopt(args, std.getopt.config.passThrough, "mode", (string mode) {
        import std.conv : to;
        runMode = wrapException(mode.to!RunMode);
    });

    if (po.helpWanted) {
        showHelp();
    } else if (runMode.isJust) {
        run(runMode.get(), args);
    } else {
        run(args);
    }
}
