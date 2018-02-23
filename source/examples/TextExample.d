module examples.TextExample;

import sbylib;
import std.algorithm, std.array;
import std.math;

void textExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


    auto camera = new OrthoCamera(2,2,-1,1);
    world.setCamera(camera);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    auto font = FontLoader.load(FontPath("meiryo.ttc"), 256);


    auto createLabel(float size, Label.OriginX ox, Label.OriginY oy, vec3 pos, vec4 color, dstring text) {
        auto label = new Label(font, size);
        label.setOrigin(ox, oy);
        label.entity.pos = pos;
        label.setColor(color);
        label.setBackColor(vec4(vec3(1) - color.rgb, 1));
        label.renderText(text);
        return label;
    }


    auto getColor(float angle) {
        angle *= PI / 180;
        return vec4(vec3(sin(angle), sin(angle-PI*2/3), sin(angle+PI*2/3)) * .5 + .5, 1);
    }


    auto labels = [
        createLabel(0.2, Label.OriginX.Center, Label.OriginY.Center, vec3(0,0,0), vec4(0,0,0,1), "abcdefghijklmnopqrstuvwxyz1234567890-^@[;:],./\\!\"#$%&'()=~`{+*}<>?_|"d),
        createLabel(0.1, Label.OriginX.Right,  Label.OriginY.Center, vec3(+1, 0,0), getColor(0),   "東"d),
        createLabel(0.1, Label.OriginX.Left,   Label.OriginY.Top,    vec3(-1,+1,0), getColor(45),  "北西"d),
        createLabel(0.1, Label.OriginX.Center, Label.OriginY.Top,    vec3( 0,+1,0), getColor(90),  "北"d),
        createLabel(0.1, Label.OriginX.Right,  Label.OriginY.Top,    vec3(+1,+1,0), getColor(135), "北東"d),
        createLabel(0.1, Label.OriginX.Left,   Label.OriginY.Center, vec3(-1, 0,0), getColor(180), "西"d),
        createLabel(0.1, Label.OriginX.Left,   Label.OriginY.Bottom, vec3(-1,-1,0), getColor(225), "南西"d),
        createLabel(0.1, Label.OriginX.Center, Label.OriginY.Bottom, vec3( 0,-1,0), getColor(270), "南"d),
        createLabel(0.1, Label.OriginX.Right,  Label.OriginY.Bottom, vec3(+1,-1,0), getColor(315), "南東"d),
    ];
    labels[0].setWrapWidth(1.5);
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

