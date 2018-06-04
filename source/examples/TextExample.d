module examples.TextExample;

import sbylib;
import std.algorithm, std.array;
import std.math;

void textExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AspectFixViewport(window);


    auto camera = new OrthoCamera(2,2,-1,1);
    world.setCamera(camera);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    auto createLabel(float size, Label.Strategy s, string y, vec2 pos, vec4 color, dstring text) {
        LabelFactory factory;
        factory.fontName = "meiryo.ttc";
        factory.strategy = s;
        factory.textColor = color;
        factory.backColor = vec4(vec3(1) - color.rgb, 1);
        factory.text = text;
        factory.wrapWidth = 1.5;
        auto label = factory.make();
        final switch (s) {
            case Label.Strategy.Left:
                label.left = pos.x;
                break;
            case Label.Strategy.Center:
                label.pos.x = pos.x;
                break;
            case Label.Strategy.Right:
                label.right = pos.x;
                break;
        }
        switch (y) {
            case "Top":
                label.top = pos.y;
                break;
            case "Center":
                label.pos.y = pos.y;
                break;
            case "Bottom":
                label.bottom = pos.y;
                break;
            default:
                assert(false);
        }
        return label;
    }


    auto getColor(float angle) {
        angle *= PI / 180;
        return vec4(vec3(sin(angle), sin(angle-PI*2/3), sin(angle+PI*2/3)) * .5 + .5, 1);
    }


    auto labels = [
        createLabel(0.2, Label.Strategy.Center, "Center", vec2(0,  0), vec4(0,0,0,1), "abcdefghijklmnopqrstuvwxyz1234567890-^@[;:],./\\!\"#$%&'()=~`{+*}<>?_|"d),
        createLabel(0.1, Label.Strategy.Right,  "Center", vec2(+1, 0), getColor(0),   "東"d),
        createLabel(0.1, Label.Strategy.Left,   "Top",    vec2(-1,+1), getColor(45),  "北西"d),
        createLabel(0.1, Label.Strategy.Center, "Top",    vec2( 0,+1), getColor(90),  "北"d),
        createLabel(0.1, Label.Strategy.Right,  "Top",    vec2(+1,+1), getColor(135), "北東"d),
        createLabel(0.1, Label.Strategy.Left,   "Center", vec2(-1, 0), getColor(180), "西"d),
        createLabel(0.1, Label.Strategy.Left,   "Bottom", vec2(-1,-1), getColor(225), "南西"d),
        createLabel(0.1, Label.Strategy.Center, "Bottom", vec2( 0,-1), getColor(270), "南"d),
        createLabel(0.1, Label.Strategy.Right,  "Bottom", vec2(+1,-1), getColor(315), "南東"d),
    ];
    foreach (label; labels) {
        world.add(label);
    }


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}

