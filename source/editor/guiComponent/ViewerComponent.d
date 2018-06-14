module editor.guiComponent.ViewerComponent;

import sbylib;
import dconfig;
import editor.guiComponent;
import editor.viewport;
import editor.pane;

import game.player;
import game.character;
import game.command;
import game.scene;
import game.Game;

import std.algorithm, std.format, std.typecons;

class ViewerComponent : AGuiComponent {

private:
    float _width;
    float _height;
    ViewerViewport _viewport;
    Pane _pane;
    bool _isActive;

public:
    this(float width, float height, Pane pane) {
        _width = width;
        _height = height;
        _pane = pane;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new ColorMaterial);
        entity.color = vec4(0); // 透明
        super(entity);

        createWorld();
        updateViewport();
    }

    override float x() {
        return super.x();
    }
    override float x(float value) {
        super.x(value);
        updateViewport();
        return super.x;
    }

    override float y() {
        return super.y();
    }
    override float y(float value) {
        super.y(value);
        updateViewport();
        return super.y;
    }

    override float width() {
        return _width;
    }

    override float height() {
        return _height;
    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        _isActive = activeControllable.isJust && activeControllable.get is this;
    }

private:
    void updateViewport() {
        _viewport.setRect(
            cast(int)(_pane.x + this.x),
            cast(int)(_pane.y + this.y - this.height),
            cast(uint)(this.width),
            cast(uint)(this.height)
        );
    }

    void createWorld() {

        /* Core Settings */
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto world2d = Game.getWorld2D();
        auto world3d = Game.getWorld3D();


        _viewport = new ViewerViewport(cast(int)x, cast(int)y, cast(uint)width, cast(uint)height, 800.0f/600.0f);


        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 200);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        world3d.setCamera(camera);


        world3d.addRenderGroup("Crystal", new TransparentRenderGroup(camera));


        world2d.setCamera(new OrthoCamera(2,2,-1,1));


        /* Player Settings */
        Game.initializePlayer(camera);
        auto player = Game.getPlayer();
        Game.getCommandManager().setReceiver(player);
        core.addProcess((proc) {
            player.step();
        }, "player update");
        core.addProcess((proc) {
            if (!_isActive) return;
            Game.update();
        }, "game update");


        auto map = new Map;
        map.crystalMine();
        Game.initializeMap(map);


        /* Label Settings */
        if (Game.getCommandManager().isPlaying()) {
            auto font = FontLoader.load(FontPath("HGRPP1.TTC"), 256);
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

        /* Compass Settings */
        auto compass = new Entity(Rect.create(0.5, 0.5), new CompassMaterial(camera));
        world2d.add(compass);
        compass.pos = vec3(0.75, -0.75, 0);


        /* FPS Observe */
        auto fpsCounter = new FpsCounter!100();
        auto fpsLabel = makeTextEntity("FPS = ", 0.1);
        fpsLabel.pos.xy = vec2(-1,1);
        //fpsLabel.setBackColor(vec4(1));
        world2d.add(fpsLabel);
        core.addProcess((proc) {
            import std.conv;
            fpsCounter.update();
            fpsLabel.renderText(format!"FPS[%d]"(cast(int)fpsCounter.getFPS()).to!dstring);
            window.setTitle(format!"FPS[%d]"(cast(int)fpsCounter.getFPS()).to!string);
        }, "fps update");


        /* Key Input */
        core.getKey().justPressed(KeyButton.Escape).add({
            Game.getCommandManager().save();
            core.end();
        });
        core.getKey().justPressed(KeyButton.KeyP).add({ConfigManager().load();});
        core.getKey().justPressed(KeyButton.Key0).add({player.setCenter(vec3(0));});
        core.getKey().justPressed(KeyButton.KeyF).add({window.toggleFullScreen();});


        /* Animation */
        core.addProcess(&AnimationManager().step, "Animation Manager");


        /* Render */
        auto renderer = new Renderer();
        core.addProcess((proc) {
            screen.clear(ClearMode.Depth);
            renderer.render(Game.getWorld3D(), screen, _viewport, "regular");
            renderer.render(Game.getWorld3D(), screen, _viewport, "transparent");
            screen.blitsTo(Game.getBackBuffer(), BufferBit.Color);
            renderer.render(Game.getWorld3D(), screen, _viewport, "Crystal");
            screen.clear(ClearMode.Depth);
            renderer.render(Game.getWorld2D(), screen, _viewport);
        }, "render");
    }

}
