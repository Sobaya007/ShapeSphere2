module editor.guiComponent.CheckBoxComponent;

import sbylib;
import editor.guiComponent;

class CheckBoxComponent : AGuiComponent {

private:
    const float _size;
    const vec4 _backColor = vec4(0.2, 0.2, 0.2, 1.0);
    const vec4 _foreColor = vec4(0.8, 0.8, 0.8, 1.0);

public:
    this(float size) {
        _size = size;
        auto geom = Rect.create(_size, _size, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new CheckBoxComponentMaterial);
        entity.backColor = _backColor;
        entity.foreColor = _foreColor;
        entity.isChecked = false;
        super(entity);
    }

    override float width() {
        return _size;
    }

    override float height() {
        return _size;
    }

    bool isChecked() @property {
        return (cast(CheckBoxComponentMaterial)entity.getMesh().get().mat).isChecked;
    }

    void check() {
        (cast(CheckBoxComponentMaterial)entity.getMesh().get().mat).isChecked ^= true;
    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {
        if (mouseButton == MouseButton.Button1 && isCollided) {
            check();
        }
    }

}
