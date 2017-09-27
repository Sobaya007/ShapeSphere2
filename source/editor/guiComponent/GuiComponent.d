module editor.guiComponent.GuiComponent;

import sbylib;
import editor.guiComponent;

interface GuiComponent : IControllable {

    float x() @property;
    float x(float) @property;
    float y() @property;
    float y(float) @property;
    size_t zIndex() @property;
    size_t zIndex(size_t) @property;
    float width() @property;
    float height() @property;

    Entity entity() @property;

}

package(editor.guiComponent) abstract class AGuiComponent : GuiComponent {

private:
    Entity _entity;

    size_t _zIndex;
    const float _zDetail = 0.1;

public:
    // zIndexが大きいほど手前で描画される
    this(float x, float y, size_t zIndex, Entity entity = null, bool createColEntryFlag = true) {
        _zIndex = zIndex;
        _entity = entity is null ? new Entity : entity;
        _entity.pos = vec3(x, y, _zDetail * zIndex);
        if (_entity.getMesh !is null && createColEntryFlag) {
            _entity.createCollisionPolygon();
        }
        _entity.setUserData(cast(void *)cast(IControllable)this);
    }

    override float x() {
        return entity.obj.pos.x;
    }
    override float x(float value) {
        return entity.obj.pos.x = value;
    }

    override float y() {
        return entity.obj.pos.y;
    }
    override float y(float value) {
        return entity.obj.pos.y = value;
    }

    override size_t zIndex() {
        return _zIndex;
    }
    override size_t zIndex(size_t value) {
        _zIndex = value;
        entity.obj.pos.z = _zDetail * _zIndex;
        return _zIndex;
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
