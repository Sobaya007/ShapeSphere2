module editor.guiComponent.ButtonComponent;

import sbylib;
import editor.guiComponent;

class ButtonComponent : AGuiComponent {

private:
    LabelComponent _label;

    vec4 _darkColor = vec4(0.2, 0.2, 0.2, 1.0);
    vec4 _lightColor = vec4(0.9, 0.9, 0.9, 1.0);
    vec4 _borderColor = vec4(0.5, 0.5, 0.5, 1.0);
    float _borderSize = 5.0;
    void delegate() _onTrigger;

    const int _duration = 20;
    int _frameCount = _duration;

public:
    this(
        float width,
        float height,
        LabelComponent label
    ) {
        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ButtonComponentMaterial)(geom);
        entity.getMesh.mat.darkColor = _darkColor;
        entity.getMesh.mat.lightColor = _lightColor;
        entity.getMesh.mat.borderColor = _borderColor;
        entity.getMesh.mat.borderSize = _borderSize;
        entity.getMesh.mat.value = 0;
        entity.getMesh.mat.size = vec2(width, height);

        _label = label;
        label.x = width/2;
        label.y = -height/2;
        label.zIndex = 1;
        label.entity.setUserData(null);
        entity.addChild(label.entity);

        setTrigger({});
        super(entity);
    }

    this(
        float width,
        float height,
        dstring text = ""d,
        float fontSize = 0.0,
        vec4 fontColor = vec4(0, 0, 0, 1)
    ) {
        LabelComponent label = new LabelComponent(text, fontSize, fontColor, Label.OriginX.Center, Label.OriginY.Center);
        this(width, height, label);
    }

    void setTrigger(void delegate() onTrigger) {
        _onTrigger = onTrigger;
    }

    void setText(dstring text) {
        _label.setText(text);
    }

    void setDarkColor(vec4 color) {
        _darkColor = color;
        (cast(ButtonComponentMaterial)entity.getMesh.mat).darkColor = _darkColor;
    }

    void setLightColor(vec4 color) {
        _lightColor = color;
        (cast(ButtonComponentMaterial)entity.getMesh.mat).lightColor = _lightColor;
    }

    void setBorderColor(vec4 color) {
        _borderColor = color;
        (cast(ButtonComponentMaterial)entity.getMesh.mat).borderColor = _borderColor;
    }

    void setBorderSize(float size) {
        _borderSize = size;
        (cast(ButtonComponentMaterial)entity.getMesh.mat).borderSize = _borderSize;
    }

    override float width() {
        return (cast(ButtonComponentMaterial)entity.getMesh.mat).size.x;
    }

    override float height() {
        return (cast(ButtonComponentMaterial)entity.getMesh.mat).size.y;
    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {
        if (mouseButton == MouseButton.Button1 && isCollided) {
            pushButton();
        }
    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        import std.math, std.algorithm;
        int t = _duration/2;
        float y = (t-_frameCount)^^2/cast(float)t^^2;
        float value = max(0, 1 - y);
        (cast(ButtonComponentMaterial)entity.getMesh.mat).value = value;
        _frameCount++;
    }

    private void pushButton() {
        _onTrigger();
        _frameCount = 0;
    }

}
