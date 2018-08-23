module sbylib.entity.utils.MultiLineLabel;

import sbylib;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

class MultiLineLabel {

    Label label;
    Entity rect;
    protected ColoredString[] text;

    alias rect this;

    static add() {
        auto world = new World;
        auto renderer = createRenderer2D(world, Core().getWindow().getScreen());
        world.add(new typeof(this));
        Core().addProcess({
            renderer.renderAll();
        }, "console render");
    }

    this() {
        LabelFactory factory;
        factory.fontName = "RictyDiminished-Regular-Powerline.ttf";
        factory.height = 24.pixel;
        factory.strategy = Label.Strategy.Left;
        factory.wrapWidth = Core().getWindow().width;
        factory.text = WHITE("");

        this.label = factory.make();
        label.pos.z = 0.1;

        this.rect = makeEntity(Rect.create(Core().getWindow.width, Core().getWindow().height), new ColorMaterial(vec4(vec3(0), 0.5)));
        this.rect.pos.z = -0.01;
        this.rect.addChild(this.label);

        text = [WHITE("")];
    }

    void render(ColoredString[] strs) {
        ColoredString total;
        foreach (str; strs[0..$-1]) total ~= str ~ WHITE("\n");
        total ~= strs[$-1];
        label.renderText(total);
        label.left = -Core().getWindow().width/2;
        label.bottom = -Core().getWindow().height/2;
    }

    void addLine(ColoredString line) {
        text ~= line;
        render(text);
    }
}
