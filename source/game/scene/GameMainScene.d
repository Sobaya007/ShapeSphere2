module game.scene.GameMainScene;
import sbylib;
import game.player;
import game.character;
import game.command;
import game.scene;
import game.Game;
import model.xfile.loader;
import std.stdio, std.getopt, std.file, std.array, std.algorithm, std.conv, std.format, std.path, std.regex, std.typecons;

class GameMainScene : SceneBase {

    mixin SceneBasePack;

    private Label[] labels;
    private debug int consoleMode = 0;

    override void initialize() {
        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto world2d = Game.getWorld2D();
        auto world3d = Game.getWorld3D();


        this.viewport = new AutomaticViewport(window);


        screen.setClearColor(vec4(0,0,0,1));


        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 200);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        world3d.setCamera(camera);


        world3d.addRenderGroup("Crystal", new TransparentRenderGroup(camera));


        world2d.setCamera(new OrthoCamera(2,2,-1,1));

        Game.initializeScene(this);


        /* Player Settings */
        Game.initializePlayer(camera);
        auto player = Game.getPlayer();
        Game.getCommandManager().setReceiver(player);
        core.addProcess(&Game.update, "game update");


        auto map = new Map;
        map.testStage2();
        Game.initializeMap(map);


        /* Label Settings */
        if (Game.getCommandManager().isPlaying()) {
            LabelFactory factory;
            factory.fontName = "HGRPP1.TTC";
            factory.height = 0.1;
            factory.strategy = Label.Strategy.Right;
            factory.textColor = vec4(1);
            factory.text = "REPLAYING...";
            auto label = factory.make();
            label.right = 1;
            label.top = 1;
            world2d.add(label);
            core.addProcess((proc) {
                if (Game.getCommandManager().isPlaying()) return;
                label.renderText("STOPPED");
                proc.kill();
            }, "label update");
        }

        core.getKey().justPressed(KeyButton.Escape).add({
            Game.getCommandManager().save();
            core.end();
        });

        debug {
            /* FPS Observe */
            auto fpsCounter = new FpsCounter!100();
            auto fpsLabel = addLabel();
            core.addProcess((proc) {
                fpsCounter.update();
                fpsLabel.renderText(format!"FPS: %3d"(fpsCounter.getFPS()).to!dstring);
                fpsLabel.top = 0.9;
                fpsLabel.left = -1;
                window.setTitle(format!"FPS[%d]"(fpsCounter.getFPS()).to!string);
            }, "fps update");

            auto numberLabel3D = addLabel("world3d");
            auto numberLabel2D = addLabel("world2d");
            core.addProcess({
                numberLabel3D.renderText(format!"World3D: %2d"(world3d.getEntityNum));
                numberLabel2D.renderText(format!"World2D: %2d"(world2d.getEntityNum));
                numberLabel3D.left = -1;
                numberLabel2D.left = -1;
            }, "label update");

            /* Control navigation */
            addLabel("Esc: Finish Game");
            addLabel("A/D: Rotate Camera");
            addLabel("Space: Press Character");
            addLabel("X: Transform to Needle");
            addLabel("C: Transform to Spring");
            addLabel("Z: Reset Camera");
            addLabel("R: Look over");
            addLabel("Arrow: Move");
            addLabel("Enter: Talk to another Character");
            addLabel("L: Reload Lights & Crystals");
            addLabel("P: Warp to debug pos (written in JSON)");
            addLabel("Q: Save current pos as debug pos");
            addLabel("0: Warp to Origin");
            addLabel("O: Reload Config");
            addLabel("F: Toggle Fullscreen");
            addLabel("T: Toggle Debug Wireframe");
            addLabel("N: Toggle this message");

            /* Key Input */
            core.getKey().justPressed(KeyButton.KeyO).add({ConfigManager().load();});
            core.getKey().justPressed(KeyButton.Key0).add({player.setCenter(vec3(0));});
            core.getKey().justPressed(KeyButton.KeyF).add({window.toggleFullScreen();});
            core.getKey().justPressed(KeyButton.KeyN).add({labels.each!(l => l.traverse!((Entity e) => e.visible = !e.visible));});
            core.getKey().justPressed(KeyButton.KeyI).add({consoleMode = 1;});

            /* Console */
            createConsole();
        } else {
            window.toggleFullScreen();
        }

        import game.stage.Stage1;
        auto stage1 = cast(Stage1)Game.getMap().stage;

        debug Game.timerStart("Total");
    }

    override void render() {
        debug Game.timerStop("Total");
        debug Game.timerStart("Total");
        debug Game.timerStart("render");
        renderer.render(Game.getWorld3D(), screen, viewport, "regular");
        renderer.render(Game.getWorld3D(), screen, viewport, "transparent");
        screen.blitsTo(Game.getBackBuffer(), BufferBit.Color);
        renderer.render(Game.getWorld3D(), screen, viewport, "Crystal");
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport, "regular");
        renderer.render(Game.getWorld2D(), screen, viewport, "transparent");
        debug Game.timerStop("render");
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
        label.top = 0.9 - labels.length * factory.height;
        Game.getWorld2D().add(label);

        labels ~= label;

        return label;
    }

    debug void createConsole() {
        LabelFactory factory;
        factory.fontName = "consola.ttf";
        factory.height = 0.06;
        factory.strategy = Label.Strategy.Left;
        factory.backColor = vec4(0,0,0,0);
        factory.textColor = vec4(1,1,1,1);
        factory.text = "Waiting...";
        auto consoleLabel = factory.make();
        consoleLabel.left = -1;
        consoleLabel.bottom = -1;
        labels ~= consoleLabel;
        Game.getWorld2D.add(consoleLabel);
        auto rect = makeColorEntity(vec4(0,0,0,0.5), 2, factory.height*6);
        rect.pos.y = -1+factory.height*3;
        Game.getWorld2D.add(rect);
        auto text = "";
        size_t cursor = 0;

        import std.ascii, std.array;
        string slice(string s, size_t i, size_t j) {
            if (i > j) return "";
            if (i < 0) return "";
            if (j > s.length) return "";
            return s[i..j];
        }

        void render() {
            auto t = slice(text,0,cursor)~'|'~slice(text,cursor, text.length);
            auto ts = t.split('\n');
            consoleLabel.renderText(ts[0..$-1].map!(t=>" "~t).join('\n')~'\n'~(consoleMode?'>':':')~ts[$-1]);
            consoleLabel.left = -1;
            consoleLabel.bottom = -1;
        }
        Core().addProcess({
            if (consoleMode == 0) return;
            if (consoleMode == 1) {
                consoleMode++;
                render();
                return;
            }
            Core().getKey().preventCallback();
            auto mKey = Core().getKey().justPressedKey();
            if (mKey.isNone) return;
            auto key = mKey.get();
            if (isPrintable(key)) {
                text = text.empty ? (cast(char)key).toLower.to!string : slice(text,0,cursor)~(cast(char)key).toLower~slice(text,cursor, text.length);
                cursor++;
            } else if (key == KeyButton.Enter) {
                auto lines = text.split('\n');
                if (!lines.empty) interpret(lines.back);
                if (lines.length < 5) {
                    text ~= '\n';
                    cursor = text.length;
                } else {
                    text = lines[$-5..$].join('\n')~'\n';
                    cursor = text.length;
                }
            } else if (key == KeyButton.BackSpace) {
                text = text.empty ? text : slice(text,0,cursor-1)~slice(text,cursor, text.length);
                cursor = max(0, cursor-1);
            } else if (key == KeyButton.Left) {
                cursor = max(0, cursor-1);
            } else if (key == KeyButton.Right) {
                cursor = min(text.length, cursor+1);
            } else if (key == KeyButton.Escape) {
                consoleMode = false;
                Core().getKey().allowCallback();
            }
            render();
        }, "");
    }

    debug void interpret(string str) {
    }
}
