module examples.TextExample;

import sbylib;
import std.algorithm, std.array;
import std.math;

void textExample() {
    
    auto universe = Universe.createFromJson(ResourcePath("world/text.json"));

    auto world = universe.getWorld("world").unwrap();

    auto createLabel(float size, Label.Strategy s, string y, vec2 pos, ColoredString text) {
        pos.xy = pos.xy * vec2(Core().getWindow().width, Core().getWindow().height) / 2;

        LabelFactory factory;
        factory.fontName = "meiryo.ttc";
        factory.strategy = s;
        factory.height = 32.pixel;
        factory.text = text;
        factory.wrapWidth = Core().getWindow().width * 0.8;
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
        createLabel(0.2, Label.Strategy.Center, "Center", vec2(0,  0), "abcdefghijklmnopqrstuvwxyz1234567890-^@[;:],./\\!\"#$%&'()=~`{+*}<>?_|".graduation(vec4(1,0,0,1), vec4(0,0,1,1))),
        createLabel(0.1, Label.Strategy.Right,  "Center", vec2(+1, 0), "東"  .colored(getColor(0))),
        createLabel(0.1, Label.Strategy.Left,   "Top",    vec2(-1,+1), "北西".colored(getColor(45))),
        createLabel(0.1, Label.Strategy.Center, "Top",    vec2( 0,+1), "北"  .colored(getColor(90))),
        createLabel(0.1, Label.Strategy.Right,  "Top",    vec2(+1,+1), "北東".colored(getColor(135))),
        createLabel(0.1, Label.Strategy.Left,   "Center", vec2(-1, 0), "西"  .colored(getColor(180))),
        createLabel(0.1, Label.Strategy.Left,   "Bottom", vec2(-1,-1), "南西".colored(getColor(225))),
        createLabel(0.1, Label.Strategy.Center, "Bottom", vec2( 0,-1), "南"  .colored(getColor(270))),
        createLabel(0.1, Label.Strategy.Right,  "Bottom", vec2(+1,-1), "南東".colored(getColor(315))),
    ];
    foreach (label; labels) {
        world.add(label);
    }


    Core().start();
}

