module game.scene.GameMainScene;

import sbylib;
import game.player;
import game.character;
import game.command;
import game.scene;
import std.stdio, std.getopt, std.file, std.array, std.algorithm, std.conv, std.format, std.path, std.regex;

class GameMainScene : SceneBase {

    static string[] args;

    mixin SceneBasePack;

    private World world2d, world3d;

    override void initialize() { 
        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        this.viewport = new AutomaticViewport(window);
        this.world2d = new World;
        this.world3d = new World;
        auto texture = Utils.generateTexture(ImageLoader.load(ImagePath("uv.png")));

        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 100);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        world3d.setCamera(camera);
        world2d.setCamera(new OrthoCamera(2,2,-1,1));

        /* Player Settings */
        auto commandManager = getCommandManager(args);
        Player player = new Player(camera, world3d, commandManager);
        auto character = new Character(world3d);
        player.floors ~= character.sphere;
        core.addProcess((proc) {
            player.step();
            character.step();
        }, "player update");
        core.addProcess(&commandManager.update, "command update");

        /* Label Settings */
        if (commandManager.isPlaying()) {
            auto font = FontLoader.load(FontPath("HGRPP1.TTC"), 256);
            auto label = new Label(font, 0.1);
            label.setOrigin(Label.OriginX.Right, Label.OriginY.Top);
            label.pos = vec3(1,1,0);
            label.setColor(vec4(1));
            label.renderText("REPLAYING...");
            world2d.add(label);
            core.addProcess((proc) {
                if (commandManager.isPlaying()) return;
                label.renderText("STOPPED");
                proc.kill();
            }, "label update");
        }

        /* Compass Settings */
        auto compass = new Entity(Rect.create(0.5, 0.5), new CompassMaterial(camera));
        world2d.add(compass);
        compass.pos = vec3(0.75, -0.75, 0);

        /* Polygon(Floor) Settings */
        auto makePolygon = (vec3[4] p) {
            auto polygons = [
            new CollisionPolygon([p[0], p[1], p[2]]),
                new CollisionPolygon([p[0], p[2], p[3]])];
            auto mat = new CheckerMaterial!(NormalMaterial, UvMaterial);
            mat.size = 0.118;
            auto geom0 = polygons[0].createGeometry();
            geom0.vertices[0].uv = vec2(1,0);
            geom0.vertices[1].uv = vec2(1,1);
            geom0.vertices[2].uv = vec2(0,1);
            geom0.updateBuffer();
            auto geom1 = polygons[1].createGeometry();
            geom1.vertices[0].uv = vec2(1,0);
            geom1.vertices[1].uv = vec2(0,1);
            geom1.vertices[2].uv = vec2(0,0);
            geom1.updateBuffer();

            Entity e0 = new Entity(geom0, mat, polygons[0]);
            Entity e1 = new Entity(geom1, mat, polygons[1]);
            world3d.add(e0);
            world3d.add(e1);
            player.floors ~= e0;
            player.floors ~= e1;
            character.floors ~= e0;
            character.floors ~= e1;
        };
        makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
        makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);

        /* Light Settings */
        PointLight pointLight;
        pointLight.pos = vec3(0,2,0);
        pointLight.diffuse = vec3(1);
        world3d.addPointLight(pointLight);

        /* Joy Stick Settings */
        core.addProcess((proc) {
            if (core.getJoyStick().canUse) {
                //writeln(core.getJoyStick());
            }
        }, "joy state");

        /* FPS Observe */
        auto fpsCounter = new FpsCounter!100();
        core.addProcess((proc) {
            fpsCounter.update();
            core.getWindow().setTitle(format!"FPS[%d]"(fpsCounter.getFPS()));
        }, "fps update");

        /* Key Input */
        core.addProcess((proc) {
            if (core.getKey[KeyButton.Escape]) {
                commandManager.save();
                core.end();
            }
            if (core.getKey[KeyButton.KeyR]) ConstantManager.reload();
        }, "po");
    }

    override void render() {
        renderer.render(world3d, screen, viewport);
        screen.clear(ClearMode.Depth);
        renderer.render(world2d, screen, viewport);
    }

    private ICommandManager getCommandManager(string[] args) {
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
