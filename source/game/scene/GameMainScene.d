module game.scene.GameMainScene;
import sbylib;
import dconfig;
import game.player;
import game.character;
import game.command;
import game.scene;
import game.Game;
import game.console.Console;
import std.stdio, std.getopt, std.file, std.array, std.algorithm, std.conv, std.format, std.path, std.regex, std.typecons;

class GameMainScene : SceneBase {

    mixin SceneBasePack;

    private debug GameConsole console;

    override void initialize() {


        /* Camera Settings */
        Camera camera = new PerspectiveCamera(16.0 / 9.0, 60.deg, 0.1, 200);
        Game.getWorld3D().setCamera(camera);
        Game.getWorld2D().setCamera(new PixelCamera);


        this.viewport = new AspectFixViewport(Core().getWindow, 16.0 / 9.0);


        Game.initializeScene(this);


        /* Player Settings */
        Game.initializePlayer(camera);
        auto player = Game.getPlayer();
        Game.getCommandManager().setReceiver(player);


        /* Map Settings */
        auto map = new Map;
        map.crystalMine();
        Game.initializeMap(map);

        debug {
            addDebugMessages();
        } else {
            Core().getWindow().toggleFullScreen();
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
        Core().addProcess((Process proc) {
            fpsCounter.update();
            fpsLabel.renderText(format!"FPS: %3d"(cast(int)fpsCounter.getFPS()).to!dstring);
            fpsLabel.top = Core().getWindow().height/2;
            fpsLabel.left = -Core().getWindow().width/2;
            Core().getWindow().setTitle(format!"FPS[%d]"(cast(int)fpsCounter.getFPS()).to!string);
        }, "fps update");

        auto numberLabel3D = Game.addLabel("world3d");
        auto numberLabel2D = Game.addLabel("world2d");
        auto collisionCountLabel = Game.addLabel("col");
        Core().addProcess({
            numberLabel3D.renderText(format!"World3D: %2d"(Game.getWorld3D().getEntityNum));
            numberLabel2D.renderText(format!"World2D: %2d"(Game.getWorld2D().getEntityNum));
            collisionCountLabel.renderText(format!"Player's collision: %2d"(Game.getPlayer().collisionCount));
            numberLabel3D.left = -Core().getWindow().width/2;
            numberLabel2D.left = -Core().getWindow().width/2;
            collisionCountLabel.left = -Core().getWindow().width/2;
        }, "label update");

        /* Label Settings */
        if (Game.getCommandManager().isPlaying()) {
            LabelFactory factory;
            factory.fontName = "HGRPP1.TTC";
            factory.height = 32.pixel;
            factory.strategy = Label.Strategy.Right;
            factory.textColor = vec4(1);
            factory.text = "REPLAYING...";
            auto label = factory.make();
            label.right = Core().getWindow().width/2;
            label.top = Core().getWindow().height/2;
            Game.getWorld2D().add(label);
            Core().addProcess((Process proc) {
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
        Core().justPressed(KeyButton.KeyO).add({ConfigManager().load(); Game.log("Config Reloaded");});
        Core().justPressed(KeyButton.Key0).add({Game.getPlayer().setCenter(vec3(0));});
        Core().justPressed(KeyButton.KeyF).add({Core().getWindow().toggleFullScreen();});
        Core().justPressed(KeyButton.KeyN).add({Game.toggleDebugLabel(); });
        Core().justPressed(KeyButton.KeyI).add({console.on();});
        Core().justPressed(KeyButton.KeyJ).add({Game.getPlayer().camera.fly(); Game.log("Start Fly Mode");});

        /* Console */
        this.console = GameConsole.add();

        /* Manipulator */
        import game.tool.manipulator;
        auto manipulatorManager = new ManipulatorManager;
        Core().addProcess((Process proc) {
            manipulatorManager.update();
        }, "manipulator update");
    }

}
