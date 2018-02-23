module game.Game;

public import game.command;
public import game.player;
public import game.stage.Map;
public import game.entity.Message;
public import game.scene.GameMainScene;
import sbylib;
import std.getopt, std.file, std.regex, std.algorithm, std.format, std.path, std.array, std.stdio, std.conv, std.datetime.stopwatch;

class Game {
static:

    private ICommandManager commandManager;

    private World world2d, world3d;

    private Player player;

    private Map map;

    private Message message;

    private RenderTarget backBuffer;

    private GameMainScene scene;

    private debug StopWatchLabel[] stopWatch;

    private debug class StopWatchLabel {

        private string name;
        private Label label;
        private StopWatch sw;

        alias sw this;

        this(string name) {
            this.name = name;
            auto factory = LabelFactory();
            factory.originX = Label.OriginX.Right;
            factory.originY = Label.OriginY.Top;
            factory.fontName = "meiryo.ttc";
            this.label = factory.make();
            this.label.setBackColor(vec4(0.5));
            this.label.pos.x = 1;

            if (stopWatch.length == 0) {
                this.label.pos.y = 1;
            } else {
                auto sw = stopWatch[$-1];
                this.label.pos.y = sw.label.pos.y - sw.label.getHeight;
            }
            getWorld2D().add(this.label);
        }
    }

    void initialize(string[] args) {
        this.commandManager = selectCommandManager(args);
        this.world2d = new World;
        this.world3d = new World;
        this.message = new Message;
        this.backBuffer = new RenderTarget(512, 512);
        this.backBuffer.attachTexture!ubyte(FrameBufferAttachType.Color0);
    }

    void initializePlayer(Camera camera) in {
        assert(this.player is null);
    } body {
        this.player = new Player(camera);
    }

    void initializeMap(Map map) in {
        assert(this.map is null);
    } body {
        this.map = map;
    }

    void initializeScene(GameMainScene) in {
        assert(this.scene is null);
    } body {
        this.scene = scene;
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

    Map getMap() in {
        assert(this.map !is null);
    } body {
        return this.map;
    }

    GameMainScene getScene() in {
        assert(this.scene !is null);
    } body {
        return this.scene;
    }

    Message getMessge() {
        return this.message;
    }

    RenderTarget getBackBuffer() {
        return this.backBuffer;
    }

    debug void timerStart(string str) {
        auto findResult = stopWatch.find!(sw => sw.name == str);
        if (findResult.empty) {
            auto sw = new StopWatchLabel(str);
            stopWatch ~= sw;
            sw.start();
        } else {
            auto sw = findResult.front;
            sw.reset();
            sw.start();
        }
    }

    debug void timerStop(string str) {
        auto findResult = stopWatch.find!(sw => sw.name == str);
        assert(!findResult.empty);
        auto sw = findResult.front;
        assert(sw.running);
        sw.label.renderText(format!"%s : %3dmsecs"(str, sw.peek.total!"msecs"));
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
