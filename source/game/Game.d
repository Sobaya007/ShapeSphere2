module game.Game;

import game.command;
import game.player;
import game.entity.Message;
import sbylib;
import std.getopt, std.file, std.regex, std.algorithm, std.format, std.path, std.array, std.stdio, std.conv;

class Game {
static:

    private ICommandManager commandManager;

    private World world2d, world3d;

    private Player player;

    private Message message;

    void initialize(string[] args) {
        this.commandManager = selectCommandManager(args);
        this.world2d = new World;
        this.world3d = new World;
        this.message = new Message;
    }

    void initializePlayer(Camera camera) in {
        assert(this.player is null);
    } body {
        this.player = new Player(camera);
    }

    ICommandManager getCommandManager() {
        return commandManager;
    }

    World getWorld2D() {
        return this.world2d;
    }

    World getWorld3D() {
        return this.world3d;
    }

    Player getPlayer() in {
        assert(this.player !is null);
    } body {
        return this.player;
    }

    Message getMessge() {
        return this.message;
    }

    void update() {
        commandManager.update();
    }

    private ICommandManager selectCommandManager(string[] args) {
        string replayDataPath;
        string historyDataPath;
        getopt(args, "replay", &replayDataPath, "history", &historyDataPath);

        if (!historyDataPath || replayDataPath == "latest") {
            if (!exists("history")) {
                mkdir("history");
            }
            auto r = regex("replay(0|([1-9][0-9]*)).history");
            auto entries = dirEntries("history", SpanMode.shallow)
                .filter!(a => a.name.baseName.matchAll(r));
            auto names = entries.map!(a => a.name.baseName[6..$-8]).array;
            auto max = names.length == 0 ? -1 : names.to!(int[]).maxElement;
            std.stdio.writeln("max = ", max);
            if (!historyDataPath) {
                historyDataPath = format!"history/replay%d.history"(max+1);
            }
            if (replayDataPath == "latest") {
                replayDataPath = format!"history/replay%d.history"(max);
            }
        }

        if (replayDataPath) return new ReplayCommandManager(replayDataPath, historyDataPath);
        return new PlayCommandManager(historyDataPath);
    }
}
