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
    debug enum CONSOLE_LINE_NUM = 30;

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
        factory.fontName = "RictyDiminished-Regular-Powerline.ttf";
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
        auto rect = makeColorEntity(vec4(0,0,0,0.5), 2, factory.height*CONSOLE_LINE_NUM);
        rect.pos.y = -1+factory.height*3;
        Game.getWorld2D.add(rect);
        auto text = [""];
        long cursor = 0;
        auto history = [""];
        long historyCursor = 0;

        import std.ascii, std.array;
        string slice(string s, size_t i, size_t j) {
            if (i > j) return "";
            if (i < 0) return "";
            if (j > s.length) return "";
            return s[i..j];
        }

        void render() {
            import std.range;
            auto lastLine = text.back;
            lastLine = slice(lastLine,0,cursor)~'|'~slice(lastLine,cursor, lastLine.length);
            consoleLabel.renderText(text.dropBack(1).map!(t=>" "~t).join('\n')~'\n'~(consoleMode?'>':':')~lastLine);
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
            Game.getMap().pause();
            auto mKey = Core().getKey().justPressedKey();
            if (mKey.isNone) return;
            auto key = mKey.get();
            if (isPrintable(key)) {
                auto shift = Core().getKey().isPressed(KeyButton.LeftShift) || Core().getKey().isPressed(KeyButton.RightShift);
                auto c = shift ? cast(char)key : (cast(char)key).toLower;
                if (c == '.' && shift) c = '>';
                text.back = slice(text.back,0,cursor)~c~slice(text.back,cursor, text.back.length);
                cursor++;
            } else if (key == KeyButton.Enter) {
                auto input = text.back;
                if (!input.empty) {
                    history ~= input;
                    historyCursor = history.length;
                    import std.range;
                    string[] output = interpret(input)
                        .split("\n")
                        .sort
                        .group
                        .map!(p => p[0].repeat(p[1]).enumerate.map!(a=>a.value~(a.index==0 ? "" : a.index.to!string)).array)
                        .join
                        .map!(s => " ".repeat(4).join~s)
                        .array;
                    text ~= output;
                }
                text ~= "";
                import std.range;
                text = text.tail(CONSOLE_LINE_NUM);
                cursor = 0;
            } else if (key == KeyButton.BackSpace) {
                text.back = slice(text.back,0,cursor-1)~slice(text.back,cursor, text.back.length);
                cursor = max(0, cursor-1);
            } else if (key == KeyButton.Left) {
                cursor = max(0, cursor-1);
            } else if (key == KeyButton.Right) {
                cursor = min(text.back.length, cursor+1);
            } else if (key == KeyButton.Up) {
                historyCursor = max(0, historyCursor-1);
                text.back = history[historyCursor];
                cursor = text.back.length;
            } else if (key == KeyButton.Down) {
                historyCursor = min(history.length, historyCursor+1);
                text.back = historyCursor < history.length ? history[historyCursor] : "";
                cursor = text.back.length;
            } else if (key == KeyButton.Escape) {
                consoleMode = false;
                Core().getKey().allowCallback();
                Game.getMap().resume();
            } else if (key == KeyButton.Tab) {
                import std.range;
                auto cs = candidates(text.back);
                if (!cs.empty) {
                    text ~= cs.map!(c => " ".repeat(4).join~c).array;
                    text ~= cs.reduce!commonPrefix;
                    text = text.tail(CONSOLE_LINE_NUM);
                    cursor = text.back.length;
                }
            }
            render();
        }, "");
    }

    debug string interpret(string str) {
        import std.range;
        auto tokens = str.split('>');
        if (tokens.empty) return "";

        if (tokens.front == "world3d") {
            return interpret(Game.getWorld3D, tokens.dropOne);
        } else if (tokens.front == "world2d") {
            return interpret(Game.getWorld2D, tokens.dropOne);
        }
        return format!"No match pattern for '%s'"(tokens.front);
    }

    debug string interpret(World world, string[] tokens) {
        import std.range;
        if (tokens.empty) return world.toString((Entity e) => e.name, false);
        auto child = world.findByName(tokens.front);
        if (child.isNone) return format!"No match name for '%s'"(tokens.front);
        return interpret(child.get(), tokens.dropOne);
    }

    debug string interpret(Entity entity, string[] tokens) {
        import std.range;
        if (tokens.empty) return entity.toString(false);
        auto token = tokens.front;
        switch (token) {
            case "pos": return entity.pos.toString;
            case "rot": return entity.rot.toString;
            case "scale": return entity.scale.toString;
            default:
        }
        auto child = entity.findByName(token);
        if (child.isNone) return format!"No match name for '%s'"(token);
        return interpret(child.get(), tokens.dropOne);
    }

    debug string[] candidates(string[] strs, string head) {
        import std.uni;
        return strs.filter!(s => s.toLower.startsWith(head.toLower)).array;
    }

    debug string[] candidates(string str) {
        import std.range;
        auto tokens = str.split('>');
        if (tokens.empty) return [];
        if (tokens.length == 1) return candidates(["world3d", "world2d"], tokens.front);
        if (tokens.front == "world3d") {
            return candidates(Game.getWorld3D, tokens.dropOne).map!(c => "world3d>"~c).array;
        } else if (tokens.front == "world2d") {
            return candidates(Game.getWorld2D, tokens.dropOne).map!(c => "world2d>"~c).array;
        }
        return [];
    }

    debug string[] candidates(World world, string[] tokens) {
        import std.range;
        if (tokens.length == 1) return candidates(world.getEntityNames, tokens.front);
        auto child = world.findByName(tokens.front);
        if (child.isNone) return [];
        return candidates(child.get(), tokens.dropOne).map!(c => tokens.front~c).array;
    }

    debug string[] candidates(Entity entity, string[] tokens) {
        import std.range;
        if (tokens.length == 1) return candidates(["pos", "rot", "scale"]~entity.getChildren.map!(c=>c.name).array, tokens.front);
        auto child = entity.findByName(tokens.front);
        if (child.isNone) return [];
        return candidates(child.get(), tokens.dropOne).map!(c => tokens.front~c).array;
    }
}
