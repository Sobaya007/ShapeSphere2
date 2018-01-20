module editor.pane.scrollBar.ScrollBar;

import sbylib;
import editor.pane;
import editor.viewport;

class ScrollBar : IControllable {

static const uint WIDTH = 20;

private:
    Entity _entity;
    ScrollBarBack _scrollBarBack;
    ScrollBarFront _scrollBarFront;

public:
    this(Pane pane, float contentHeight) {
        Core core = Core();
        auto window = core.getWindow();
        auto screen = window.getScreen();
        auto camera = new OrthoCamera(1, 1, -1, 1);
        auto viewport = new PaneViewport(window, camera, pane.x + pane.width - WIDTH, pane.y, WIDTH, pane.height);
        auto world = new World;
        camera.obj.pos = vec3(viewport.getWidth / 2, viewport.getHeight /2, 0);
        world.setCamera(camera);

        auto renderer = new Renderer();
        auto render = delegate (Process proc) {
            // TODO clear
            renderer.render(world, screen, viewport);
        };

        auto control = new GuiControl(window, camera, viewport, world, core.getKey());

        core.addProcess(render, "render");
        core.addProcess(&control.update, "control");

        /* Scroll Bar */
        _scrollBarBack = new ScrollBarBack(WIDTH, pane.height);
        _scrollBarFront = new ScrollBarFront(WIDTH, pane.height * pane.height/contentHeight, viewport.getHeight);
        _scrollBarBack.getEntity.addChild(_scrollBarFront.getEntity);

        _entity = _scrollBarBack.getEntity;
        _entity.pos.x = 0;
        _entity.pos.y = pane.height;

        control.add(this);
    }

    override Entity getEntity() {
        return _entity;
    }

    override void onMousePressed(MouseButton mouseButton) {

    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {

    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        _scrollBarBack.update(mouse, activeControllable);
        _scrollBarFront.update(mouse, activeControllable);
    }

private:
}
