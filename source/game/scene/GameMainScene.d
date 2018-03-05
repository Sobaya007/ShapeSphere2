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
            auto font = FontLoader.load(FontPath("HGRPP1.TTC"), 256);
            auto label = new Label(font, 0.1);
            label.setOrigin(Label.OriginX.Right, Label.OriginY.Top);
            label.pos = vec3(1,1,0);
            label.setColor(vec4(1));
            label.renderText("REPLAYING...");
            world2d.add(label);
            core.addProcess((proc) {
                if (Game.getCommandManager().isPlaying()) return;
                label.renderText("STOPPED");
                proc.kill();
            }, "label update");
        }


        /* Compass Settings */
        auto compass = new Entity(Rect.create(0.5, 0.5), new CompassMaterial(camera));
        world2d.add(compass);
        compass.pos = vec3(0.75, -0.75, 0);

        /* FPS Observe */
        auto fpsCounter = new FpsCounter!100();
        auto fpsLabel = addLabel();
        core.addProcess((proc) {
            fpsCounter.update();
            fpsLabel.renderText(format!"FPS: %d"(fpsCounter.getFPS()).to!dstring);
            window.setTitle(format!"FPS[%d]"(fpsCounter.getFPS()).to!string);
        }, "fps update");

        /* Control navigation */
        addLabel("A/D: Rotate Camera");
        addLabel("Space: Press Character");
        addLabel("X: Transform to Needle");
        addLabel("C: Transform to Spring");
        addLabel("Z: Reset Camera");
        addLabel("R: Look over");
        addLabel("Arrow: Move");
        addLabel("Enter: Talk to another Character");
        addLabel("L: Reload Lights & Crystals");
        addLabel("P: Warp");
        addLabel("0: Warp to Origin");
        addLabel("F: Toggle Fullscreen");
        addLabel("T: Toggle Debug Wireframe");
        addLabel("N: Toggle this message");

        /* Key Input */
        core.getKey().justPressed(KeyButton.Escape).add({
            Game.getCommandManager().save();
            core.end();
        });
        core.getKey().justPressed(KeyButton.KeyP).add({ConfigManager().load();});
        core.getKey().justPressed(KeyButton.Key0).add({player.setCenter(vec3(0));});
        core.getKey().justPressed(KeyButton.KeyF).add({window.toggleFullScreen();});
        core.getKey().justPressed(KeyButton.KeyN).add({labels.each!(l => l.traverse!((Entity e) => e.visible = !e.visible));});

        import game.stage.Stage1;
        auto stage1 = cast(Stage1)Game.getMap().stage;

        import core.thread;
        new Thread({
            while (true) {
                try {
                    void write(string str) {
                        import std.stdio: stdWrite = write;
                        stdWrite("\033[35m");
                        stdWrite(str);
                        stdWrite("\033[39m");
                    }
                    void writeln(string str) {
                        write(str ~ '\n');
                    }
                    write(" > ");
                    import std.string;
                    auto line = readln.chomp;
                    auto res = Pattern(line)
                        .match!((l) => l == "player.pos")(player.getCenter().toString)
                        .match!((l) => l == "world3d.entities")(world3d.getEntities.map!(e => e.toString).join("\n"))
                        .match!((l) => l == "add crystal here")({stage1.addCrystal(player.getCenter); return "Successfully Added Crystal";}())
                        .match!((l) => l == "add light here")({stage1.addLight(player.getCenter); return "Successfully Added Light";}())
                        .other("no match pattern for '" ~ line ~ "'");
                    writeln(res);
                    stdout.flush;
                } catch (Error e) {
                    e.writeln;
                }
            }
        }).start();

        /* Manipulator */
        import game.tool.manipulator;
        auto manipulatorManager = new ManipulatorManager;
        core.addProcess((proc) {
            manipulatorManager.update();
        }, "manipulator update");

    }

    override void render() {
        renderer.render(Game.getWorld3D(), screen, viewport, "regular");
        renderer.render(Game.getWorld3D(), screen, viewport, "transparent");
        screen.blitsTo(Game.getBackBuffer(), BufferBit.Color);
        renderer.render(Game.getWorld3D(), screen, viewport, "Crystal");
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport, "regular");
        renderer.render(Game.getWorld2D(), screen, viewport, "transparent");
    }

    Label addLabel(dstring text = "") {
        auto factory = LabelFactory();
        factory.text = text;
        factory.originX = Label.OriginX.Left;
        factory.originY = Label.OriginY.Top;
        factory.fontName = "meiryo.ttc";
        auto label = factory.make();
        label.pos.xy = vec2(-1,1 - labels.length * factory.height);
        label.setBackColor(vec4(vec3(1), 0.4));
        Game.getWorld2D().add(label);

        labels ~= label;

        return label;
    }
}
