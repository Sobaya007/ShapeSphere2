module sbylib.entity.utils.LogEntity;

public {
    import sbylib.entity.Entity;
    import sbylib.animation.Animation;
    import sbylib.math.Vector;
    import sbylib.character.Label;
}

import sbylib.wrapper.freetype.Font;

private struct LogEntityInfo {
    string fontName = "WaonJoyo-R.otf";
    float size = 0.1;
    int fontResolution = 256;
    Label.Strategy strategy = Label.Strategy.Center;
    float wrapWidth = float.infinity;
    int rowNum = 4;
}

struct LogFactory {

    LogEntityInfo info;
    alias info this;

    auto make() {
        return new LogEntity(info);
    }
}

class LogEntity {

    Entity entity;
    alias entity this;

    private LogEntityInfo info;
    private Label[] labels;

    this(LogEntityInfo info) {
        this.entity = new Entity;
        this.info = info;
    }

    void insert(string text) {
        import sbylib.utils.Path;
        import sbylib.utils.Loader;
        with (info) {
            auto font = FontLoader.load(FontPath(fontName), fontResolution);
            auto label = new Label(font, size, wrapWidth, strategy, BLACK(text));
            
            label.pos.y = rowNum * size;

            entity.addChild(label);
            labels ~= label;

            enum FRAME = 10.frame;


            import sbylib;
            auto animate(Label label, float y, float a) {
                AnimationManager().startAnimation(
                    animation(
                        (float y) {label.pos.y = y;},
                        setting(
                            label.pos.y, y, FRAME, Ease.InOut
                        )
                    )
                );
                return AnimationManager().startAnimation(
                    animation(
                        (float a) {label.alpha = a;},
                        setting(
                            1-a, a, FRAME, Ease.InOut
                        )
                    )
                );
            }
            //i番目の人はi*sizeにいる
            if (labels.length <= rowNum) {
                animate(label, (labels.length-1)*size, 1);
            } else {
                auto front = labels[0];
                labels = labels[1..$];

                foreach (i; 0..labels.length) {
                    animate(labels[i], i*size, 1);
                }
                animate(front, -size, 0).onFinish({ front.remove(); front.destroy();});
            }
        }
    }

    auto width() {
        import std.algorithm, std.array;
        return labels.empty ? 0 : labels.map!(l => l.width).maxElement;
    }

    auto height() {
        return labels.length * info.size;
    }

    auto left(float v) {
        foreach (label; labels) label.left = v;
        return v;
    }

    auto right(float v) {
        foreach (label; labels) label.right = v;
        return v;
    }

    auto top(float v) {
        foreach (label; labels) label.top = v;
        return v;
    }

    auto bottom(float v) {
        foreach (label; labels) label.bottom = v;
        return v;
    }
}
