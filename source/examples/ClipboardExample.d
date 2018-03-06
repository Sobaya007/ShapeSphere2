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
    LabelFactory factory;
    factory.fontName = "meiryo.ttc";
    factory.height = 0.2;
    factory.wrapWidth = size;
    factory.text = labelText;
    auto label = factory.make();
    world.add(label);


    auto backEntity = makeEntity(Rect.create(size, size), new ColorMaterial(vec4(1)));
    backEntity.pos = label.pos.get();
    backEntity.pos.z -= 0.1;
    world.add(backEntity);


    bool onCopyKeyPressed() {
        return core.getKey.justPressed(KeyButton.KeyC);
    }
    bool onPasteKeyPressed() {
        return core.getKey.justPressed(KeyButton.KeyV);
    }

    Clipboard clipboard = core.getClipboard;
    core.getKey.justPressed(KeyButton.KeyC).add({ clipboard.set(labelText); });
    core.getKey.justPressed(KeyButton.KeyV).add({
        import std.format, std.conv, std.algorithm;
        enum maximum = 100;
        dstring pasteText = clipboard.get();
        dstring errorText = format!"'%s ... ' is too long."(pasteText[0..min($, maximum)]).to!dstring;
        if (pasteText.length > maximum) {
            label.renderText(labelText = errorText);
        } else {
            label.renderText(labelText = clipboard.get());
        }
    });


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}
