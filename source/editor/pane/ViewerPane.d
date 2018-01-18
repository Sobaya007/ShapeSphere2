module editor.pane.ViewerPane;

import sbylib;

import editor.guiComponent;
import editor.viewport;
import editor.pane;

import game.player;
import game.command;

class ViewerPane : GuiPane {

private:

public:
    this(int x, int y, uint width, uint height) {
        super(x, y, width, height);
    }

protected:
    override GuiComponent createContent() {
        auto core = Core();

        auto viewer = new ViewerComponent(this.width, this.height, this);

        return viewer;
    }

}
