module examples.ClipboardExample;

import sbylib;

void clipboardExample() {
    auto world = createFromJson(ResourcePath("world/clipboard.json")).at("world2D").get().world;

    Label label = world.findByName("label")
        .wrapRange
        .getOrError("label was not found")
        .getUserData!(Label)("Label")
        .getOrError("type mismatch");


    Clipboard clipboard = Core().getClipboard;
    Core().getKey.justPressed(KeyButton.KeyC).add({ clipboard.set(label.text); });
    Core().getKey.justPressed(KeyButton.KeyV).add({
        import std.format, std.conv, std.algorithm;
        enum maximum = 100;
        dstring pasteText = clipboard.get();
        dstring errorText = format!"'%s ... ' is too long."(pasteText[0..min($, maximum)]).to!dstring;
        if (pasteText.length > maximum) {
            label.renderText(errorText);
        } else {
            label.renderText(clipboard.get());
        }
    });


    Core().start();
}
