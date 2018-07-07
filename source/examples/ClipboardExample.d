module examples.ClipboardExample;

import sbylib;

void clipboardExample() {
    auto universe = Universe.createFromJson(ResourcePath("world/clipboard.json"));

    auto world = universe.getWorld("world").unwrap();

    Label label = world.findByName("label")
        .wrapRange
        .wrapCast!(Label)
        .unwrap();

    Clipboard clipboard = Core().getClipboard;
    Core().justPressed(KeyButton.KeyC).add({ clipboard.set(label.text); });
    Core().justPressed(KeyButton.KeyV).add({
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
