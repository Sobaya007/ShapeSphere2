module sbylib.entity.utils.TextEntity;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Animation;
    import sbylib.math.Vector;
    import sbylib.character.Label;
}

import sbylib.wrapper.freetype.Font;

struct LabelFactory {
    string fontName = "WaonJoyo-R.otf";
    float height = 0.1;
    int fontResolution = 256;
    Label.Strategy strategy = Label.Strategy.Center;
    float wrapWidth = float.infinity;
    vec4 textColor = vec4(0,0,0,1);
    vec4 backColor = vec4(0);
    dstring text = "";

    auto make() {
        import sbylib.utils.Path;
        import sbylib.utils.Loader;
        auto font = FontLoader.load(FontPath(fontName), fontResolution);
        return new Label(font, height, wrapWidth, strategy, textColor, backColor, text);
    }
}

auto makeTextEntity(dstring text, float height) {
    LabelFactory factory;
    factory.text = text;
    factory.height = height;
    return factory.make();
}

auto colorAnimation(Label label, AnimSetting!vec4 evaluator) {
    return
        animation((vec4 color) {
            label.color = color;
        }, evaluator);
}
