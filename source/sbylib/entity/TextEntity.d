module sbylib.entity.TextEntity;

public import sbylib.entity.Entity;
public import sbylib.animation.Animation;
public import sbylib.math.Vector;

import sbylib.wrapper.freetype.Font;
import sbylib.wrapper.freetype.FontLoader;
import sbylib.character.Label;
import sbylib.utils.Path;

private Font font;

Label TextEntity(dstring text, float height, Label.OriginX originX = Label.OriginX.Center, Label.OriginY originY = Label.OriginY.Center) {
    if (font is null) font = FontLoader.load(FontPath("meiryo.ttc"), 256);
    auto label = new Label(font, height);
    label.setOrigin(originX, originY);
    label.renderText(text);
    return label;
}

IAnimation color(Label label, AnimSetting!vec4 evaluator) {
    return
        new Animation!vec4((vec4 color) {
            label.setColor(color);
        }, evaluator);
}
