module editor.pane.ViewerPane;

import sbylib;

import editor.guiComponent;
import editor.viewport;
import editor.pane;

import game.player;
import game.command;

class ViewerPane : GuiPane {

private:
    ViewerComponent _viewer;

public:
    this(int x, int y, uint width, uint height) {
        super(x, y, width, height);
    }

protected:
    override void createContent(GuiControl control) {
        auto core = Core();

        _viewer = new ViewerComponent(this.width, this.height, this);
        _viewer.x = 0;
        _viewer.y = height;
        control.add(_viewer);
    }

}
