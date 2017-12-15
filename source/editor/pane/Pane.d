module editor.pane.Pane;

import sbylib;

import editor.guiComponent;
import editor.viewport;


abstract class Pane {

private:
    int x;
    int y;
    uint width;
    uint height;

public:

    this(int x, int y, uint width, uint height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;

        Core core = Core();

        auto window = core.getWindow();
        auto screen = window.getScreen();
        screen.setClearColor(vec4(0.3, 0.3, 0.3, 1.0));
        auto camera = new OrthoCamera(1, 1, -1, 1);
        auto viewport = new PaneViewport(window, camera, x, y, width, height);
        auto world = new World;
        camera.getObj.pos = vec3(viewport.getWidth / 2, viewport.getHeight /2, 0);
        world.setCamera(camera);

        auto renderer = new Renderer();
        auto render = delegate (Process proc) {
            screen.clear(ClearMode.Color, ClearMode.Depth);
            renderer.render(world, screen, viewport);
        };

        auto control = new GuiControl(window, camera, viewport, world, core.getKey());

        createContent(control);

        core.addProcess(render, "render");
        core.addProcess(&control.update, "control");
    }

protected:
    void createContent(GuiControl control);
}
