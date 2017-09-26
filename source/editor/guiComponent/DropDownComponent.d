module editor.guiComponent.DropDownComponent;

import sbylib;
import editor.guiComponent;

import std.algorithm;

class DropDownComponent : AGuiComponent {

private:
    MainNodeComponent _mainNode;
    ListNodeComponent[] _nodes;

    int _selectedIndex = -1;
    bool _isOpen = false;

public:
    this(
        float x,
        float y,
        size_t zIndex,
        float width,
        float height,
        dstring[] textList,
        float fontSize = 0.0,
        vec4 fontColor = vec4(0, 0, 0, 1)
    ) {
        Entity root = new Entity;

        _mainNode = new MainNodeComponent(0, 0, 1, width, height, ""d, fontSize, fontColor, this);
        root.addChild(_mainNode.entity);

        _nodes.length = textList.length;
        foreach(int i, text; textList) {
            _nodes[i] = new ListNodeComponent(0, -((i + 1)*height), 0, width, height, text, fontSize, fontColor, this, i);
            root.addChild(_nodes[i].entity);
        }

        super(x, y, zIndex, root);
    }

    override float width() {
        return _mainNode.width;
    }

    override float height() {
        return _mainNode.height;
    }

    override void update(Mouse2D mouse) {
        _mainNode.update(mouse);
        _nodes.each!(
            node => node.update(mouse)
        );
    }

    void setIndex(int index) {
        _selectedIndex = index;
    }

    package {
        bool isOpen() {
            return _isOpen;
        }
        void selectNode(ListNodeComponent node) {
            setIndex(node.index);
            _mainNode.setText(node.text);
        }

        void open() {
            _isOpen = true;
            _nodes.each!(
                node => node.open()
            );
        }

        void close() {
            _isOpen = false;
            _nodes.each!(
                node => node.close()
            );
        }
    }

}

package class MainNodeComponent : AGuiComponent {

private:
    DropDownComponent _owner;
    LabelComponent _labelComponent;

    const vec4 _darkColor = vec4(0.1, 0.1, 0.1, 1.0);
    const vec4 _lightColor = vec4(0.9, 0.0, 0.0, 1.0);
    const vec4 _borderColor = vec4(0.6, 0.6, 0.6, 1.0);
    const float _borderSize = 5.0;

    const int _duration = 20;
    int _frameCount = _duration;

public:
    this(
        float x,
        float y,
        int zIndex,
        float width,
        float height,
        dstring text,
        float fontSize,
        vec4 fontColor,
        DropDownComponent owner
    ) {
        _owner = owner;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ButtonComponentMaterial)(geom);
        entity.getMesh.mat.darkColor = _darkColor;
        entity.getMesh.mat.lightColor = _lightColor;
        entity.getMesh.mat.borderColor = _borderColor;
        entity.getMesh.mat.borderSize = _borderSize;
        entity.getMesh.mat.value = 0;
        entity.getMesh.mat.size = vec2(width, height);

        _labelComponent = new LabelComponent(width/2, -height/2, 1, text, fontSize, fontColor, Label.OriginX.Center, Label.OriginY.Center);
        _labelComponent.entity.setUserData(null);
        entity.addChild(_labelComponent.entity);

        super(x, y, zIndex, entity);
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

    override void update(Mouse2D mouse) {
        import std.math, std.algorithm;
        int t = _duration/2;
        float y = (t-_frameCount)^^2/cast(float)t^^2;
        float value = max(0, 1 - y);
        (cast(ButtonComponentMaterial)entity.getMesh.mat).value = value;
        _frameCount++;
    }

    void setText(dstring text) {
        _labelComponent.setText(text);
    }

    private void pushButton() {
        _frameCount = 0;

        if (_owner.isOpen) {
            _owner.close();
        } else {
            _owner.open();
        }
    }

}

package class ListNodeComponent : AGuiComponent {

private:
    DropDownComponent _owner;
    const int _index;
    const dstring _text;
    const float _maxY;

    const vec4 _darkColor = vec4(0.1, 0.1, 0.1, 1.0);
    const vec4 _lightColor = vec4(0.0, 0.0, 0.9, 1.0);
    const vec4 _borderColor = vec4(0.6, 0.6, 0.6, 1.0);
    const float _borderSize = 5.0;

    const int _duration = 20;
    int _frameCount = _duration;

    bool _isOpen;
    bool _isClosed;

public:
    this(
        float x,
        float y,
        int zIndex,
        float width,
        float height,
        dstring text,
        float fontSize,
        vec4 fontColor,
        DropDownComponent owner,
        int index
    ) {
        _owner = owner;
        _index = index;
        _text = text;
        _maxY = y;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ButtonComponentMaterial)(geom);
        entity.getMesh.mat.darkColor = _darkColor;
        entity.getMesh.mat.lightColor = _lightColor;
        entity.getMesh.mat.borderColor = _borderColor;
        entity.getMesh.mat.borderSize = _borderSize;
        entity.getMesh.mat.value = 0;
        entity.getMesh.mat.size = vec2(width, height);
        auto labelComponent = new LabelComponent(width/2, -height/2, 1, text, fontSize, fontColor, Label.OriginX.Center, Label.OriginY.Center);
        labelComponent.entity.setUserData(null);
        entity.addChild(labelComponent.entity);
        super(x, 0, zIndex, entity);
    }

    override float width() @property {
        return (cast(ButtonComponentMaterial)entity.getMesh.mat).size.x;
    }

    override float height() @property {
        return (cast(ButtonComponentMaterial)entity.getMesh.mat).size.y;
    }

    float getY() {
        return entity.obj.pos.y;
    }

    void setY(float y) {
        entity.obj.pos.y = y;
    }

    dstring text() @property {
        return _text;
    }

    int index() @property {
        return _index;
    }

    void open() {
        _isOpen = true;
        _isClosed = false;
    }

    void close() {
        _isOpen = false;
        _isClosed = true;
    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {
        if (mouseButton == MouseButton.Button1 && isCollided) {
            pushButton();
        }
    }

    override void update(Mouse2D mouse) {
        import std.math, std.algorithm;
        int t = _duration/2;
        float y = (t-_frameCount)^^2/cast(float)t^^2;
        float value = max(0, 1 - y);
        (cast(ButtonComponentMaterial)entity.getMesh.mat).value = value;
        _frameCount++;

        move();
    }

    private void pushButton() {
        _frameCount = 0;
        _owner.selectNode(this);
        _owner.close();
    }

    private void move() in {
        assert(!_isOpen || !_isClosed);
    } body {
        float targetY = _isOpen ? _maxY : _isClosed ? 0 : getY;

        float a = 0.5;
        setY(a*targetY + (1 - a)*getY);
    }

}
