module examples.ClipboardExample;

import sbylib;

void clipboardExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


    auto camera = new OrthoCamera(2,2,-1,1);
    world.setCamera(camera);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    dstring labelText = "Press C to copy here, or press V to paste here."d;
    float size = 1.8;

    // label
    auto font = FontLoader.load(FontPath("meiryo.ttc"), 256);
    auto label = new Label(font, 0.2);
    label.setOrigin(Label.OriginX.Center, Label.OriginY.Center);
    label.entity.pos = vec3(0);
    label.setWrapWidth(size);
    label.setColor(vec4(0,0,0,1));
    label.renderText(labelText);
    world.add(label);


    auto backEntity = makeEntity(Rect.create(size, size), new ColorMaterial(vec4(1)));
    backEntity.pos = label.getPos(Label.OriginX.Center, Label.OriginY.Center);
    backEntity.pos.z -= 0.1;
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


    core.addProcess({
        if (core.getKey().justPressed(KeyButton.Escape)) {
            core.end();
        }
    }, "escape");


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}
