module examples.text2d;

import sbylib;
import std.algorithm, std.array;
import std.math;

void mainText2d() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new Bahamut;
    auto leviathan = new Leviathan();
    auto camera = new OrthoCamera(2,2,-1,1);
    auto font = FontLoader.load(RESOURCE_ROOT ~ "HGRPP1.TTC", 256);
    auto label = new Label(font);
    label.setSize(0.2);
    label.setOrigin(Label.OriginX.Center, Label.OriginY.Center);
    label.entity.obj.pos = vec3(0);
    label.setWrapWidth(2);
    label.setColor(vec4(0,0,0,1));
    label.renderText("くぁwせdrftgyふじこlp"d);

    auto label2 = new Label(font);
    label2.setSize(0.1);
    label2.setOrigin(Label.OriginX.Left, Label.OriginY.Top);
    label2.entity.obj.pos = vec3(-1,1,0);
    label2.setColor(getColor(45));
    label2.renderText("北西"d);

    auto label3 = new Label(font);
    label3.setSize(0.1);
    label3.setOrigin(Label.OriginX.Right, Label.OriginY.Top);
    label3.entity.obj.pos = vec3(1,1,0);
    label3.setColor(getColor(135));
    label3.renderText("北東"d);

    auto label4 = new Label(font);
    label4.setSize(0.1);
    label4.setOrigin(Label.OriginX.Left, Label.OriginY.Bottom);
    label4.entity.obj.pos = vec3(-1,-1,0);
    label4.setColor(getColor(225));
    label4.renderText("南西"d);

    auto label5 = new Label(font);
    label5.setSize(0.1);
    label5.setOrigin(Label.OriginX.Right, Label.OriginY.Bottom);
    label5.entity.obj.pos = vec3(1,-1,0);
    label5.setColor(getColor(315));
    label5.renderText("南東"d);

    auto label6 = new Label(font);
    label6.setSize(0.1);
    label6.setOrigin(Label.OriginX.Center, Label.OriginY.Top);
    label6.entity.obj.pos = vec3(0,1,0);
    label6.setColor(getColor(90));
    label6.renderText("北"d);

    auto label7 = new Label(font);
    label7.setSize(0.1);
    label7.setOrigin(Label.OriginX.Center, Label.OriginY.Bottom);
    label7.entity.obj.pos = vec3(0,-1,0);
    label7.setColor(getColor(270));
    label7.renderText("南"d);

    auto label8 = new Label(font);
    label8.setSize(0.1);
    label8.setOrigin(Label.OriginX.Left, Label.OriginY.Center);
    label8.entity.obj.pos = vec3(-1,0,0);
    label8.setColor(getColor(180));
    label8.renderText("西"d);

    auto label9 = new Label(font);
    label9.setSize(0.1);
    label9.setOrigin(Label.OriginX.Right, Label.OriginY.Center);
    label9.entity.obj.pos = vec3(1,0,0);
    label9.setColor(getColor(0));
    label9.renderText("東"d);


    screen.clearColor = vec4(0.2);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    world.camera = camera;
    world.add(label.entity);
    world.add(label2.entity);
    world.add(label3.entity);
    world.add(label4.entity);
    world.add(label5.entity);
    world.add(label6.entity);
    world.add(label7.entity);
    world.add(label8.entity);
    world.add(label9.entity);
    core.addProcess(render, "render");

    core.start();
}

vec4 getColor(float angle) {
    angle *= PI / 180;
    return vec4(vec3(sin(angle), sin(angle-PI*2/3), sin(angle+PI*2/3)) * .5 + .5, 1);
}
