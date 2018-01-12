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

    override void initialize() {
        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        this.viewport = new AutomaticViewport(window);
        auto world2d = Game.getWorld2D();
        auto world3d = Game.getWorld3D();
        auto texture = Utils.generateTexture(ImageLoader.load(ImagePath("uv.png")));

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
        auto po = [
            tuple("そばやさんってかっこいいよね"d, vec3(0,1, 6)),
            tuple("最近街ではそばやさんって人が人気なんだ"d, vec3(10,1, 4)),
            tuple("そばやさん...イケメンだよなぁ..."d, vec3(-14,1, 10)),
            tuple("キャーそばやさんよー！抱いてー！！"d, vec3(4,1, -6)),
        ];
        Character[] characters;
        foreach (pair; po) {
            auto chara = new Character(world3d, pair[0]);
            chara.setCenter(pair[1]);
            characters ~= chara;
        }
        characters.each!(character => player.collisionEntities ~= character.collisionArea);
        core.addProcess((proc) {
            player.step();
            characters.each!(character => character.step());
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

        /* Compass Settings */
        auto compass = new Entity(Rect.create(0.5, 0.5), new CompassMaterial(camera));
        world2d.add(compass);
        compass.pos = vec3(0.75, -0.75, 0);


        foreach (character; characters) {
            character.initialize();
        }

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
                Game.getCommandManager().save();
                core.end();
            }
            if (core.getKey[KeyButton.KeyR]) ConstantManager.reload();
        }, "po");
    }

    override void render() {
        renderer.render(Game.getWorld3D(), screen, viewport);
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport);
    }
}
