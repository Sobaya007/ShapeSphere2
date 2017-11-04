module editor.guiComponent.LabelComponent;

import sbylib;
import editor.guiComponent;

class LabelComponent : AGuiComponent {

private:
    Label _label;
    float _fontSize;

public:
    this(Label label) {
        _label = label;
        super(label.entity);
    }

    this(
        dstring text,
        float fontSize,
        vec4 fontColor,
        Label.OriginX originX = Label.OriginX.Left,
        Label.OriginY originY = Label.OriginY.Top,
        float wrapWidth = 1e10
    ) {

        auto font = FontLoader.load(RESOURCE_ROOT ~ "meiryo.ttc", 256);
        auto label = new Label(font, fontSize);
        label.setColor(fontColor);
        label.setOrigin(originX, originY);
        label.setWrapWidth(wrapWidth);
        label.renderText(text);
        _fontSize = fontSize;

        this(label);
    }

    override float width() {
        return _label.getWidth();
    }

    override float height() {
        return _label.getHeight();
    }

    float getFontSize() {
        return _fontSize;
    }

    void setText(dstring text) {
        _label.renderText(text);
    }

    Label getLabel() {
        return _label;
    }

}
