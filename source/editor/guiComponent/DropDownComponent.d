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
        float width,
        float height,
        dstring[] textList,
        float fontSize = 0.0
    ) {
        Entity root = new Entity;
        vec4 fontColor = vec4(0, 0, 0, 1);

        _mainNode = new MainNodeComponent(width, height, ""d, fontSize, fontColor, this);
        _mainNode.zIndex = 1;
        root.addChild(_mainNode.entity);

        _nodes.length = textList.length;
        foreach(int i, text; textList) {
            _nodes[i] = new ListNodeComponent(-((i + 1)*height), width, height, text, fontSize, fontColor, this, i);
            root.addChild(_nodes[i].entity);
        }

        super(root);
    }

    override float width() {
        return _mainNode.width;
    }

    override float height() {
        return _mainNode.height + _nodes.map!"a.height".sum;
    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        _mainNode.update(mouse, activeControllable);
        _nodes.each!(
            node => node.update(mouse, activeControllable)
        );
    }

    int getIndex() {
        return _selectedIndex;
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
    ButtonComponentMaterial material;

    const vec4 _darkColor = vec4(0.3, 0.3, 0.3, 1.0);
    const vec4 _lightColor = vec4(0.95, 0.95, 0.95, 1.0);
    const vec4 _borderColor = vec4(0.4, 0.4, 0.4, 1.0);
    const float _borderSize = 5.0;

    const int _duration = 20;
    int _frameCount = _duration;

public:
    this(
        float width,
        float height,
        dstring text,
        float fontSize,
        vec4 fontColor,
        DropDownComponent owner
    ) {
        _owner = owner;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new ButtonComponentMaterial);
        this.material = entity.mat;
        this.material.darkColor = _darkColor;
        this.material.lightColor = _lightColor;
        this.material.borderColor = _borderColor;
        this.material.borderSize = _borderSize;
        this.material.value = 0;
        this.material.size = vec2(width, height);

        _labelComponent = new LabelComponent(text, fontSize, fontColor, Label.OriginX.Center, Label.OriginY.Center);
        _labelComponent.x = width/2;
        _labelComponent.y = -height/2;
        _labelComponent.zIndex = 1;
        _labelComponent.entity.setUserData(null);
        _labelComponent.setFontColor(fontColor);
        entity.addChild(_labelComponent.entity);

        super(entity);
    }

    override float width() {
        return this.material.size.x;
    }

    override float height() {
        return this.material.size.y;
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
        this.material.value = value;
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
    ButtonComponentMaterial material;
    const int _index;
    const dstring _text;
    const float _bottomY;

    const vec4 _darkColor = vec4(0.3, 0.3, 0.3, 1.0);
    const vec4 _lightColor = vec4(0.9, 0.9, 0.9, 1.0);
    const vec4 _borderColor = vec4(0.4, 0.4, 0.4, 1.0);
    const float _borderSize = 5.0;

    const int _duration = 20;
    int _frameCount = _duration;

    bool _isOpen;
    bool _isClosed;

public:
    this(
        float bottomY,
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
        _bottomY = bottomY;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new ButtonComponentMaterial);
        this.material = entity.mat;
        this.material.darkColor = _darkColor;
        this.material.lightColor = _lightColor;
        this.material.borderColor = _borderColor;
        this.material.borderSize = _borderSize;
        this.material.value = 0;
        this.material.size = vec2(width, height);
        auto labelComponent = new LabelComponent(text, fontSize, fontColor, Label.OriginX.Center, Label.OriginY.Center);
        labelComponent.x = width/2;
        labelComponent.y = -height/2;
        labelComponent.zIndex = 1;
        labelComponent.entity.setUserData(null);
        entity.addChild(labelComponent.entity);
        super(entity);
    }

    override float width() @property {
        return this.material.size.x;
    }

    override float height() @property {
        return this.material.size.y;
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

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        import std.math, std.algorithm;
        int t = _duration/2;
        float y = (t-_frameCount)^^2/cast(float)t^^2;
        float value = max(0, 1 - y);
        this.material.value = value;
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
        float targetY = _isOpen ? _bottomY : _isClosed ? 0 : y;

        float a = 0.5;
        y = a*targetY + (1 - a)*y;
    }

}
