module examples.ClipboardExample;

import sbylib;

void clipboardExample() {
    auto universe = Universe.createFromJson(ResourcePath("world/clipboard.json"));

    auto world = universe.getWorld("world").get();

    Label label = world.findByName("label")
        .wrapRange
        .get()
        .getUserData!(Label)("Label")
        .get();


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
