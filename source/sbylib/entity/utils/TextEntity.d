module sbylib.entity.utils.TextEntity;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Animation;
    import sbylib.math.Vector;
    import sbylib.character.Label;
}

import sbylib.wrapper.freetype.Font;

private Font font;

auto makeTextEntity(dstring text, float height, Label.OriginX originX = Label.OriginX.Center, Label.OriginY originY = Label.OriginY.Center) {
    import sbylib.wrapper.freetype.FontLoader;
    import sbylib.utils.Path;
    if (font is null) font = FontLoader.load(FontPath("WaonJoyo-R.otf"), 256);
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
