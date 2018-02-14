module editor.pane.Pane;

import sbylib;

import editor.guiComponent;
import editor.viewport;
import editor.pane;

import std.algorithm;

interface Pane {
    int x() @property;
    int y() @property;
    uint width() @property;
    uint height() @property;
}

abstract class GuiPane : Pane {

protected:
    int _x;
    int _y;
    uint _width;
    uint _height;

    GuiComponent _content;
    ScrollBar _scrollBar;

public:

    this(int x, int y, uint width, uint height) {
        _x = x;
        _y = y;
        _width = width;
        _height = height;

        auto core = Core();

        auto window = core.getWindow();
        auto screen = window.getScreen();
        screen.setClearColor(vec4(0.3, 0.3, 0.3, 1.0));
        auto camera = new OrthoCamera(1, 1, -1, 1);
        auto viewport = new PaneViewport(window, camera, x, y, width, height);
        auto world = new World;
        camera.obj.pos = vec3(viewport.getWidth / 2, viewport.getHeight /2, 0);
        world.setCamera(camera);

        auto renderer = new Renderer();
        auto render = delegate (Process proc) {
            renderer.render(world, screen, viewport);
        };

        auto control = new GuiControl(window, camera, viewport, world, core.getKey());

        core.addProcess(render, "render");
        core.addProcess(&control.update, "control");

        _content = createContent();
        _content.x = 0;
        _content.y = height;
        control.add(_content);

        _scrollBar = new ScrollBar(this, _content.height);
    }

    override int x() @property {
        return _x;
    }

    override int y() @property {
        return _y;
    }

    override uint width() @property {
        return _width;
    }

    override uint height() @property {
        return _height;
    }

protected:
    GuiComponent createContent();
}
