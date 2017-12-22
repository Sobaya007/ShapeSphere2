module editor.guiComponent.ViewerComponent;

import sbylib;
import editor.guiComponent;
import editor.viewport;
import editor.pane;

import game.player;
import game.command;

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
        auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom);
        entity.getMesh.mat.color = vec4(0); // 透明
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
        auto core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto renderer = new Renderer();
        _viewport = new ViewerViewport(cast(int)x, cast(int)y, cast(uint)width, cast(uint)height, 800.0f/600.0f);
        auto world3d = new World;

        /* Camera Settings */
        Camera camera = new PerspectiveCamera(1, 60.deg, 0.1, 100);
        camera.pos = vec3(3, 2, 9);
        camera.lookAt(vec3(0,2,0));
        world3d.setCamera(camera);

        /* Player Settings */
        auto commandManager = new PlayCommandManager("");
        Player player = new Player(camera, world3d, commandManager);
        core.addProcess((proc) {
            player.step();
        }, "player update");
        core.addProcess((proc) {
            if (!_isActive) return;
            commandManager.update();
        }, "command update");


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
            player.floors.addChild(e0);
            player.floors.addChild(e1);
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


        /* Render */
        core.addProcess((proc) {
            screen.clear(ClearMode.Depth);
            renderer.render(world3d, screen, _viewport);
        }, "render");


        /* Key Input */
        core.addProcess((proc) {
            if (core.getKey[KeyButton.Escape]) {
                commandManager.save();
                core.end();
            }
            if (core.getKey[KeyButton.KeyR]) ConstantManager.reload();
        }, "po");
    }

}
