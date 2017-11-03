module examples.ClipboardExample;

import sbylib;

void clipboardExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);
    auto world = new World;
    auto camera = new OrthoCamera(2,2,-1,1);
    world.setCamera(camera);

    screen.setClearColor(vec4(0.2));
    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };
    core.addProcess(render, "render");

    dstring labelText = "Press C to copy here, or press V to paste here."d;
    float size = 1.8;

    // label
    auto font = FontLoader.load(RESOURCE_ROOT ~ "meiryo.ttc", 256);
    auto label = new Label(font, 0.2);
    label.setOrigin(Label.OriginX.Center, Label.OriginY.Center);
    label.entity.obj.pos = vec3(0);
    label.setWrapWidth(size);
    label.setColor(vec4(0,0,0,1));
    label.renderText(labelText);
    world.add(label);

    auto backMat = new ColorMaterial();
    backMat.color = vec4(1);
    auto backEntity = new Entity(Rect.create(size, size), backMat);
    backEntity.obj.pos = label.getPos(Label.OriginX.Center, Label.OriginY.Center);
    world.add(backEntity);

    bool onCopyKeyPressed() {
        return core.getKey.justPressed(KeyButton.KeyC);
    }
    bool onPasteKeyPressed() {
        return core.getKey.justPressed(KeyButton.KeyV);
    }

    Clipboard clipboard = core.getClipboard;
    core.addProcess({
        import std.stdio, std.format, std.conv, std.algorithm;
        int maximum = 100;

        if (onCopyKeyPressed()) {
            clipboard.set(labelText);
        }

        if (onPasteKeyPressed()) {
            dstring pasteText = clipboard.get();
            dstring errorText = format!"'%s ... ' is too long."(pasteText[0..min($, maximum)]).to!dstring;
            if (pasteText.length > maximum) {
                label.renderText(labelText = errorText);
            } else {
                label.renderText(labelText = clipboard.get());
            }
        }

    }, "clipboard");

    core.start();
}
