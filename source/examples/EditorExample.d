module examples.EditorExample;

import sbylib;

import editor.guiComponent;

import std.stdio;

void editorExample() {
    auto core = Core();
    auto window = core.getWindow();
    // window.setSize(1600, 1200);
    auto screen = window.getRenderTarget();
    auto world2d = new World;
    screen.clearColor = vec4(0.2);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world2d.render(screen);
    };

    float w = screen.width;
    float h = screen.height;

    // [0, 800]✕[0, 600]
    auto camera = new OrthoCamera(w, h, -1, 1);
    camera.getObj.pos = vec3(w/2, h/2, 0);
    world2d.setCamera(camera);

    auto control = new GuiControl(window, camera, world2d);

    auto spacer = new SpacerComponent(0, h, 0, 400, 300);
    control.add(spacer);
    auto label = new LabelComponent(0.0, h-300, 0, "D is 神"d, 50, vec4(0.6, 0.7, 0.8, 1.0));
    control.add(label);
    auto checkBox = new CheckBoxComponent(w/2, h, 0, 40);
    control.add(checkBox);
    auto button = new ButtonComponent(w/2, h/4*3, 0, 300, 40, "犯人は"d, 25);


    dstring[] ary = ["ONONONON!!!!", "アカーーーーン！！！！", "簡単すぎィィィ！！！！"];
    control.add(button);
    auto dropDown = new DropDownComponent(w/3, h/5*2, 0, 400, 40, ary, 25, vec4(1, 1, 1, 1));
    control.add(dropDown);
    auto groupBox = new GroupBoxComponent(10, h/3, 1, 200, "バイ成ィ"d, new CheckBoxComponent(0, 0, 0, 40));
    control.add(groupBox);

    int t = 0;
    button.setTrigger({
        import std.stdio;
        import std.algorithm;
        int i = dropDown.getIndex;
        dstring po = i<0 ? "@_n_ari！！！！"d : ary[i];
        auto a = new LabelComponent(10.0, h-20-t, 2, po, 50, vec4(0, 0, 0, 1.0));
        t += 50;
        control.add(a);
        button.writeln;
    });


    core.addProcess(render, "render");
    core.addProcess(&control.update, "control");

    core.start();
}
