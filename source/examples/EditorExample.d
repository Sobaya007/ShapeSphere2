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
    auto button = new ButtonComponent(w/2, h/4*3, 0, 300, 40, "犯人は@_n_ari！！！！"d, 25);
    button.setTrigger({
        import std.stdio;
        button.writeln;
    });
    auto dropDown = new DropDownComponent(w/3, h/5*2, 0, 400, 40, ["ONONONON!!!!", "アカーーーーン！！！！"], 25, vec4(1, 1, 1, 1));
    control.add(dropDown);

    control.add(button);

    core.addProcess(render, "render");
    core.addProcess(&control.update, "control");

    core.start();
}
