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

    private RenderTarget backBuffer;

    override void initialize() {
        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto world2d = Game.getWorld2D();
        auto world3d = Game.getWorld3D();


        this.viewport = new AutomaticViewport(window);


        this.backBuffer = new RenderTarget(256, 256);
        this.backBuffer.attachRenderBuffer(FrameBufferAttachType.Depth);
        this.backBuffer.attachTexture!ubyte(FrameBufferAttachType.Color0);


        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 200);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        world3d.setCamera(camera);


        world2d.setCamera(new OrthoCamera(2,2,-1,1));


        /* Player Settings */
        Game.initializePlayer(camera);
        auto player = Game.getPlayer();
        Game.getCommandManager().setReceiver(player);
        core.addProcess((proc) {
            player.step();
        }, "player update");
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


        /* Image Setting */


        /* Compass Settings */
        auto compass = new Entity(Rect.create(0.5, 0.5), new CompassMaterial(camera));
        world2d.add(compass);
        compass.pos = vec3(0.75, -0.75, 0);


        /* FPS Observe */
        auto fpsCounter = new FpsCounter!100();
        auto fpsLabel = makeTextEntity("FPS = ", 0.1, Label.OriginX.Left, Label.OriginY.Top);
        fpsLabel.pos.xy = vec2(-1,1);
        fpsLabel.setBackColor(vec4(1));
        world2d.add(fpsLabel);
        core.addProcess((proc) {
            fpsCounter.update();
            fpsLabel.renderText(format!"FPS[%d]"(fpsCounter.getFPS()).to!dstring);
        }, "fps update");


        /* Key Input */
        core.getKey().justPressed(KeyButton.Escape).add({
            Game.getCommandManager().save();
            core.end();
        });
        core.getKey().justPressed(KeyButton.KeyP).add({ConfigManager().load();});
        core.getKey().justPressed(KeyButton.Key0).add({player.setCenter(vec3(0));});
        core.getKey().justPressed(KeyButton.KeyF).add({window.toggleFullScreen();});
    }

    override void render() {
        renderer.render(Game.getWorld3D(), screen, viewport);
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport);

        screen.blitsTo(backBuffer, BufferBit.Color);
    }
}
