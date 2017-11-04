module editor.guiComponent.SpacerComponent;

import sbylib;
import editor.guiComponent;

class SpacerComponent : AGuiComponent {

private:
    float _width;
    float _height;

public:
    this(float width, float height) {
        _width = width;
        _height = height;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom);
        entity.getMesh.mat.color = vec4(0); // 透明
        entity.getMesh.mat.color = vec4(1, 1, 1, 1); // debug
        super(entity);
    }

    override float width() {
        return _width;
    }

    override float height() {
        return _height;
    }

}
