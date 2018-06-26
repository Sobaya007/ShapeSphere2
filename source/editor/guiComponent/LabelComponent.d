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
        super(label);
    }

    this(
        dstring text,
        float fontSize,
        vec4 fontColor,
        Label.Strategy strategy = Label.Strategy.Left,
        float wrapWidth = 1e10
    ) {

        LabelFactory factory;
        factory.fontName = "meiryo.ttc";
        factory.height = fontSize;
        factory.wrapWidth = wrapWidth;
        factory.textColor = fontColor;
        factory.strategy = strategy;
        factory.text = text;
        auto label = factory.make();
        _fontSize = fontSize;

        this(label);
    }

    override float width() {
        return _label.width;
    }

    override float height() {
        return _label.height;
    }

    float getFontSize() {
        return _fontSize;
    }

    void setFontColor(vec4 color) {
        _label.color = color;
    }

    void setText(dstring text) {
        _label.renderText(text);
    }

    Label getLabel() {
        return _label;
    }

}
