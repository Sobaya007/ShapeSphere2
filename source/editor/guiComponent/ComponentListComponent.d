module editor.guiComponent.ComponentListComponent;

import sbylib;
import editor.guiComponent;

import std.algorithm;

class ComponentListComponent : AGuiComponent {

    enum Direction {
        Vertical, Horizontal
    }

private:
    Direction _direction;
    GuiComponent[] _components;

public:
    this(
        Direction direction,
        GuiComponent[] components...
    ) {
        _direction = direction;
        _components = components.dup;

        Entity root = new Entity;
        vec2 acc = vec2(0);
        foreach(component; components) {
            component.x = isVertical() ? 0 : acc.x;
            component.y = isVertical() ? acc.y : 0;
            root.addChild(component.entity);
            acc += vec2(component.width, -component.height);
        }
        super(root);
    }

    override float width() {
        return isVertical() ?
              _components.map!"a.width".fold!max(0f)
            : _components.map!"a.width".sum;
    }

    override float height() {
        return isVertical() ?
              _components.map!"a.height".sum
            : _components.map!"a.height".fold!max(0f);
    }

    override void update(ViewportMouse mouse) {
        _components.each!(
            component => component.update(mouse)
        );
    }

    bool isVertical() {
        return _direction == Direction.Vertical;
    }

    bool isHorizontal() {
        return _direction == Direction.Horizontal;
    }

}
