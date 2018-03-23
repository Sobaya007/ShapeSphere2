module game.scene.GameMainScene;
import sbylib;
import game.player;
import game.character;
import game.command;
import game.scene;
import game.Game;
import game.Console;
import std.stdio, std.getopt, std.file, std.array, std.algorithm, std.conv, std.format, std.path, std.regex, std.typecons;

class GameMainScene : SceneBase {

    mixin SceneBasePack;

    private debug Console console;

    override void initialize() {
        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto world2d = Game.getWorld2D();
        auto world3d = Game.getWorld3D();


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


        /* Map Settings */
        auto map = new Map;
        map.testStage2();
        Game.initializeMap(map);

        debug {
            addDebugMessages();
        } else {
            window.toggleFullScreen();
        }

        debug Game.startTimer("Total");
    }

    override void render() {
        debug Game.stopTimer("Total");
        debug Game.startTimer("Total");
        debug Game.startTimer("render");
        Game.getMap().render();
        debug Game.stopTimer("render");
    }

    private debug void addDebugMessages() {
        /* FPS Observe */
        auto fpsCounter = new FpsCounter!100();
        auto fpsLabel = Game.addLabel();
        Core().addProcess((proc) {
            fpsCounter.update();
            fpsLabel.renderText(format!"FPS: %3d"(fpsCounter.getFPS()).to!dstring);
            fpsLabel.top = 0.9;
            fpsLabel.left = -1;
            Core().getWindow().setTitle(format!"FPS[%d]"(fpsCounter.getFPS()).to!string);
        }, "fps update");

        auto numberLabel3D = Game.addLabel("world3d");
        auto numberLabel2D = Game.addLabel("world2d");
        auto collisionCountLabel = Game.addLabel("col");
        Core().addProcess({
                numberLabel3D.renderText(format!"World3D: %2d"(Game.getWorld3D().getEntityNum));
                numberLabel2D.renderText(format!"World2D: %2d"(Game.getWorld2D().getEntityNum));
                collisionCountLabel.renderText(format!"Player's collision: %2d"(Game.getPlayer().collisionCount));
                numberLabel3D.left = -1;
                numberLabel2D.left = -1;
                collisionCountLabel.left = -1;
                }, "label update");

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
            Game.getWorld2D().add(label);
            Core().addProcess((proc) {
                if (Game.getCommandManager().isPlaying()) return;
                label.renderText("STOPPED");
                proc.kill();
            }, "label update");
        }

        /* Control navigation */
        Game.addLabel("Esc: Finish Game");
        Game.addLabel("A/D: Rotate Camera");
        Game.addLabel("Space: Press Character");
        Game.addLabel("X: Transform to Needle");
        Game.addLabel("C: Transform to Spring");
        Game.addLabel("Z: Reset Camera");
        Game.addLabel("R: Look over");
        Game.addLabel("Arrow: Move");
        Game.addLabel("Enter: Talk to another Character");
        Game.addLabel("L: Reload Lights & Crystals");
        Game.addLabel("P: Warp to debug pos (written in JSON)");
        Game.addLabel("Q: Save current pos as debug pos");
        Game.addLabel("0: Warp to Origin");
        Game.addLabel("O: Reload Config");
        Game.addLabel("F: Toggle Fullscreen");
        Game.addLabel("T: Toggle Debug Wireframe");
        Game.addLabel("N: Toggle this message");
        Game.addLabel("I: Goto Console Mode");
        Game.addLabel("J: Goto Fly Mode");

        /* Key Input */
        Core().getKey().justPressed(KeyButton.KeyO).add({ConfigManager().load();});
        Core().getKey().justPressed(KeyButton.Key0).add({Game.getPlayer().setCenter(vec3(0));});
        Core().getKey().justPressed(KeyButton.KeyF).add({Core().getWindow().toggleFullScreen();});
        Core().getKey().justPressed(KeyButton.KeyN).add({Game.toggleDebugLabel(); });
        Core().getKey().justPressed(KeyButton.KeyI).add({console.on();});
        Core().getKey().justPressed(KeyButton.KeyJ).add({Game.getPlayer().camera.fly();});

        /* Console */
        this.console = new Console;
        Core().addProcess(&console.step, "console");
    }

}
