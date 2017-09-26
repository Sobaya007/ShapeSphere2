module editor.guiComponent.LabelComponent;

import sbylib;
import editor.guiComponent;

class LabelComponent : AGuiComponent {

private:
    Label _label;

public:
    this(float x, float y, size_t zIndex, Label label) {
        _label = label;
        super(x, y, zIndex, label.entity);
    }

    this(
        float x,
        float y,
        size_t zIndex,
        dstring text,
        float fontSize,
        vec4 fontColor,
        Label.OriginX originX = Label.OriginX.Left,
        Label.OriginY originY = Label.OriginY.Top,
        float wrapWidth = 1e10
    ) {

        auto font = FontLoader.load(RESOURCE_ROOT ~ "HGRPP1.TTC", 256); // TODO
        auto label = new Label(font);
        label.setSize(fontSize);
        label.setColor(fontColor);
        label.setOrigin(originX, originY);
        label.setWrapWidth(wrapWidth);
        label.renderText(text);

        this(x, y, zIndex, label);
    }

    override float width() {
        // TODO
        return 10;
    }

    override float height() {
        // TODO
        return 100;
    }

    void setText(dstring text) {
        _label.renderText(text);
    }

}
