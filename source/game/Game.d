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

    private debug Label[] debugLabels;
    private debug StopWatchLabel[] stopWatch;

    private debug class StopWatchLabel {

        private string name;
        private Label label;
        private StopWatch sw;

        private long[] history;
        private long sum;

        alias sw this;

        this(string name) {
            this.name = name;
            auto factory = LabelFactory();
            factory.strategy = Label.Strategy.Left;
            factory.height = 0.07;
            factory.fontName = "consola.ttf";
            factory.backColor = vec4(0.5);
            factory.text = "poyo";
            this.label = factory.make();
            this.label.right = 1;

            if (stopWatch.length == 0) {
                this.label.top = 0.9;
            } else {
                auto sw = stopWatch[$-1];
                this.label.pos.y = sw.label.pos.y - sw.label.getHeight;
            }
            getWorld2D().add(this.label);
        }

        ulong update(long newValue) {
            if (history.length < 100) {
                history ~= newValue;
                sum += newValue;
            } else {
                sum += newValue - history.front;
                foreach (i; 1..history.length) {
                    history[i-1] = history[i];
                }
                history[$-1] = newValue;
            }
            return sum / history.length;
        }
    }

    debug Label addLabel(dstring text = "") {
        auto factory = LabelFactory();
        factory.text = text;
        factory.strategy = Label.Strategy.Left;
        factory.fontName = "meiryo.ttc";
        factory.height = 0.06;
        factory.backColor = vec4(vec3(1), 0.4);
        auto label = factory.make();
        label.left = -1;
        label.top = 0.9 - debugLabels.length * factory.height;
        Game.getWorld2D().add(label);

        debugLabels ~= label;

        return label;
    }

    debug void toggleDebugLabel() {
        static bool visible = true;
        visible = !visible;
        debugLabels.each!(label => label.traverse((Entity e) { e.visible = visible; }));
        stopWatch.each!(sw => sw.label.traverse((Entity e) { e.visible = visible; }));
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

    void initializeScene(GameMainScene scene) in {
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

    debug void startTimer(string str) {
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

    debug void stopTimer(string str) {
        auto findResult = stopWatch.find!(sw => sw.name == str);
        assert(!findResult.empty);
        auto sw = findResult.front;
        assert(sw.running);
        auto dur = sw.peek.total!"msecs";
        auto ave = sw.update(dur);
        sw.label.renderText(format!"%s : %3dmsecs"(str, ave));
        sw.label.right = 1;
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
