module editor.guiComponent.GuiComponent;

import sbylib;
import editor.guiComponent;

interface GuiComponent : IControllable {

    float x() @property;
    float x(float) @property;
    float y() @property;
    float y(float) @property;
    float width() @property;
    float height() @property;

    Entity entity() @property;

}

package(editor.guiComponent) abstract class AGuiComponent : GuiComponent {

private:
    Entity _entity;

public:
    // zIndexが大きいほど手前で描画される
    this(float x, float y, size_t zIndex, Entity entity = null) {
        _entity = entity is null ? new Entity : entity;
        _entity.pos = vec3(x, y, 0.1 * zIndex);
        if (_entity.getMesh !is null) {
            _entity.createCollisionPolygon();
        }
        _entity.setUserData(cast(void *)cast(IControllable)this);
    }

    override float x() {
        return entity.pos.x;
    }

    override float x(float value) {
        return entity.pos.x = value;
    }

    override float y() {
        return entity.pos.y;
    }

    override float y(float value) {
        return entity.pos.y = value;
    }

    abstract override float width();
    abstract override float height();

    override Entity entity() {
        return _entity;
    }

    // IControllable
    override Entity getEntity() {
        return entity;
    }
    override void onMousePressed(MouseButton mouseButton) {}
    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {}
    override void update(Mouse2D mouse) {}

}
