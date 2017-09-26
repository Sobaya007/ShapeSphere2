module editor.guiComponent.CheckBoxComponent;

import sbylib;
import editor.guiComponent;

class CheckBoxComponent : AGuiComponent {

private:
    const float _size;
    const vec4 _backColor = vec4(0.2, 0.2, 0.2, 1.0);
    const vec4 _foreColor = vec4(0.8, 0.8, 0.8, 1.0);

public:
    this(float x, float y, size_t zIndex, float size) {
        _size = size;
        auto geom = Rect.create(_size, _size, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, CheckBoxComponentMaterial)(geom);
        entity.getMesh.mat.backColor = _backColor;
        entity.getMesh.mat.foreColor = _foreColor;
        entity.getMesh.mat.isChecked = false;
        super(x, y, zIndex, entity);
    }

    override float width() {
        return _size;
    }

    override float height() {
        return _size;
    }

    bool isChecked() @property {
        return (cast(CheckBoxComponentMaterial)entity.getMesh().mat).isChecked;
    }

    void check() {
        (cast(CheckBoxComponentMaterial)entity.getMesh().mat).isChecked ^= true;
    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {
        if (mouseButton == MouseButton.Button1 && isCollided) {
            check();
        }
    }

}
