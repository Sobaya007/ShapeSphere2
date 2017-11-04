module examples.EditorExample;

import sbylib;

import editor.guiComponent;

import std.stdio;

void editorExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);
    auto world = new World;

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    float w = screen.getWidth;
    float h = screen.getHeight;

    // [0, 800]✕[0, 600]
    auto camera = new OrthoCamera(w, h, -1, 1);
    camera.getObj.pos = vec3(w/2, h/2, 0);
    world.setCamera(camera);

    auto control = new GuiControl(window, camera, world);

    auto spacer = new SpacerComponent(400, 300);
    auto label = new LabelComponent("D is 神"d, 50, vec4(0.6, 0.7, 0.8, 1.0));
    auto button = new ButtonComponent(300, 40, "犯人は"d, 25);

    dstring[] ary = ["ONONONON!!!!", "アカーーーーン！！！！", "簡単すぎィィィ！！！！"];
    auto dropDown = new DropDownComponent(400, 40, ary, 25, vec4(1, 1, 1, 1));
    auto groupBox = new GroupBoxComponent(200, "バイ成ィ"d, new CheckBoxComponent(40));

    int t = 0;
    button.setTrigger({
        import std.stdio;
        import std.algorithm;
        int i = dropDown.getIndex;
        dstring po = i<0 ? "@_n_ari！！！！"d : ary[i];
        auto a = new LabelComponent(po, 50, vec4(0, 0, 0, 1.0));
        a.x = 10;
        a.y = h-20-t;
        a.zIndex = 2;
        t += 50;
        control.add(a);
    });

    auto leftComponent = new ComponentListComponent(
        ComponentListComponent.Direction.Vertical,
        spacer, label, groupBox
    );
    leftComponent.y = h;
    control.add(leftComponent);

    auto threeCheckBox = new ComponentListComponent(
        ComponentListComponent.Direction.Horizontal,
        new CheckBoxComponent(20), new CheckBoxComponent(30), new CheckBoxComponent(40)
    );
    auto rightComponent = new ComponentListComponent(
        ComponentListComponent.Direction.Vertical,
        threeCheckBox, button, dropDown
    );
    rightComponent.x = w/2;
    rightComponent.y = h;
    control.add(rightComponent);


    core.addProcess(render, "render");
    core.addProcess(&control.update, "control");

    core.start();
}