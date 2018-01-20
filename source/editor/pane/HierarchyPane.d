module editor.pane.HierarchyPane;

import sbylib;

import editor.guiComponent;
import editor.viewport;
import editor.pane;


class HierarchyPane : GuiPane {
    this() {
        int x = 0;
        int y = 0;
        uint width = 300;
        uint height = 900;
        super(x, y, width, height);
    }

protected:
    override GuiComponent createContent() {
        auto core = Core();

        float w = 1200;
        float h = 900;
        auto dropDown = new DropDownComponent(300, 40, ["aaaa", "bbbb"], 35);

        return dropDown;
    }

}
