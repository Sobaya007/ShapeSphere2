module sbylib.entity.utils.TextEntity;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Animation;
    import sbylib.math.Vector;
    import sbylib.character.Label;
}

import sbylib.wrapper.freetype.Font;

struct LabelFactory {
    dstring text = "";
    float height = 0.1;
    Label.OriginX originX = Label.OriginX.Center;
    Label.OriginY originY = Label.OriginY.Center;
    string fontName = "WaonJoyo-R.otf";
    int fontResolution = 256;

    auto make() {
        import sbylib.utils.Path;
        import sbylib.utils.Loader;
        auto font = FontLoader.load(FontPath(fontName), fontResolution);
        auto label = new Label(font, height);
        label.setOrigin(originX, originY);
        label.renderText(text);
        return label;
    }
}

auto makeTextEntity(dstring text, float height, Label.OriginX originX = Label.OriginX.Center, Label.OriginY originY = Label.OriginY.Center) {
    return LabelFactory(text, height, originX, originY).make();
}

IAnimation color(Label label, AnimSetting!vec4 evaluator) {
    return
        new Animation!vec4((vec4 color) {
            label.setColor(color);
        }, evaluator);
}
