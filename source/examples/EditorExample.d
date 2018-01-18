module examples.EditorExample;

import sbylib;

import editor.guiComponent;
import editor.viewport;
import editor.pane;

import game.Game;

import std.stdio;

void editorExample(string[] args) {
    const WINDOW_WIDTH = 1500;
    const WINDOW_HEIGHT = 900;

    Core.config.windowWidth  = WINDOW_WIDTH;
    Core.config.windowHeight = WINDOW_HEIGHT;

    auto core = Core();
    Game.initialize(args);

    auto screen = core.getWindow().getScreen();
    core.addProcess((){
        screen.clear(ClearMode.Color, ClearMode.Depth);
    }, "clear");

    Pane pane = new TestPane(900, 0, 600, WINDOW_HEIGHT);
    Pane hierarchyPane = new HierarchyPane();
    Pane viewerPane = new ViewerPane(300, 0, 600, WINDOW_HEIGHT);

    core.start();
}

class TestPane : GuiPane {
    this(int x, int y, int width, int height) {
        super(x, y, width, height);
    }

protected:
    override GuiComponent createContent() {
        auto core = Core();

        float w = 1200;
        float h = 900;

        auto spacer = new SpacerComponent(400, 400);
        auto label = new LabelComponent("D is 神"d, 50, vec4(0.6, 0.7, 0.8, 1.0));
        auto button = new ButtonComponent(500, 50, "犯人は"d, 40);

        dstring[] ary = ["ONONONON!!!!", "アカーーーーン！！！！", "簡単すぎィィィ！！！！"];
        auto dropDown = new DropDownComponent(500, 50, ary, 35);
        auto groupBox = new GroupBoxComponent(500, "バイ成ィ"d, new CheckBoxComponent(40));

        auto textArea = new TextAreaComponent(400, 300, 30);
        textArea.setClipboard(core.getClipboard);

        button.setTrigger({
            int i = dropDown.getIndex;
            if (i < 0) return;
            button.setText(ary[i]);
        });


        auto component = new ComponentListComponent(
            ComponentListComponent.Direction.Vertical,
            spacer, label, groupBox, textArea, dropDown, button
        );

        return component;
    }
}
