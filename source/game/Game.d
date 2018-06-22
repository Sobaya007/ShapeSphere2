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
    private debug StopWatchLabel[string] stopWatch;
    private debug LogEntity logEntity;

    private debug class StopWatchLabel {

        private string name;
        private Label label;

        private TimeCounter!100 counter;
        alias counter this;

        this(string name) {
            this.name = name;
            auto factory = LabelFactory();
            factory.strategy = Label.Strategy.Left;
            factory.height = 24.pixel;
            factory.fontName = "consola.ttf";
            factory.backColor = vec4(0.5);
            factory.text = "poyo";
            this.label = factory.make();

            this.counter = new TimeCounter!100;

            auto index = stopWatch.keys.length;
            getWorld2D().add(this.label);
            this.label.addProcess({
                this.label.renderText(format!"%s : %3.2fmsecs"(this.name, stopWatch[this.name].averageTime));
                this.label.top = Core().getWindow().height/2 - label.height * index;
                this.label.right = (Core().getWindow().width/2).pixel;
            });
        }
    }

    debug Label addLabel(dstring text = "") {
        auto factory = LabelFactory();
        factory.text = text;
        factory.strategy = Label.Strategy.Left;
        factory.fontName = "meiryo.ttc";
        factory.height = 24.pixel;
        factory.backColor = vec4(vec3(1), 0.4);
        auto label = factory.make();
        auto index = debugLabels.length;
        label.addProcess({
            label.left = -Core().getWindow().width/2;
            label.top = Core().getWindow().height/2 - index * factory.height;
        });
        Game.getWorld2D().add(label);

        debugLabels ~= label;

        return label;
    }

    debug void toggleDebugLabel() {
        static bool visible = true;
        visible = !visible;
        debugLabels.each!(label => label.traverse((Entity e) { e.visible = visible; }));
        stopWatch.values.each!(sw => sw.label.traverse((Entity e) { e.visible = visible; }));
    }

    void initialize(string[] args) {
        this.commandManager = selectCommandManager(args);
        this.world2d = new World;
        this.world3d = new World;
        this.message = new Message;
        this.backBuffer = new RenderTarget(512, 512);
        this.backBuffer.attachTexture!ubyte(FrameBufferAttachType.Color0);

        debug {
            LogFactory factory;
            factory.fontName = "consola.ttf";
            factory.strategy = Label.Strategy.Right;
            factory.textColor = vec4(1);
            factory.size = 24.pixel;
            factory.rowNum = 10;
            this.logEntity = factory.make();
            this.logEntity.pos.y = -Core().getWindow().height/2;
            this.world2d.add(this.logEntity);
        }
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
        if (auto sw = str in stopWatch) {
            sw.start();
        } else {
            auto sw = new StopWatchLabel(str);
            stopWatch[str] = sw;
            sw.start();
        }
    }

    debug void stopTimer(string str) {
        auto sw = stopWatch[str];
        sw.stop();
    }

    debug void log(dstring text) {
        this.logEntity.insert(text);
        this.logEntity.right = 0.95;
    }


    void update() {
        debug Game.startTimer("Game");
        commandManager.update();
        map.step();
        debug Game.stopTimer("Game");
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
