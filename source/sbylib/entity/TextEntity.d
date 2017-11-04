module sbylib.entity.TextEntity;

public import sbylib.entity.Entity;

import sbylib.wrapper.freetype.Font;
import sbylib.wrapper.freetype.FontLoader;
import sbylib.character.Label;
import sbylib.utils.Path;

private Font font;

Entity TextEntity(dstring text, float height) {
    if (font is null) font = FontLoader.load(FontPath("meiryo.ttc"), 256);
    auto label = new Label(font, height);
    label.renderText(text);
    return label;
}
