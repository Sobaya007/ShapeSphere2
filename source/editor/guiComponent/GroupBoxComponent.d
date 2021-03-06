module editor.guiComponent.GroupBoxComponent;

import sbylib;
import editor.guiComponent;

class GroupBoxComponent : AGuiComponent {

private:
    dstring _name;

    GuiComponent _opener;
    GuiComponent _content;
    GroupBoxComponentMaterial material;

    bool _isOpen = true;

    vec4 _borderColor = vec4(1, 1, 1, 1);
    float _borderSize = 30;

public:
    this(
        float width,
        dstring name,
        GuiComponent content
    ) {
        _name = name;

        _content = content;
        _content.x = _content.x + _borderSize;
        _content.y = _content.y - _borderSize;
        _content.zIndex = 1;

        auto geom = Rect.create(width, _content.height + 2*_borderSize, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new GroupBoxComponentMaterial);
        this.material = entity.mat;

        this.material.borderColor = _borderColor;
        this.material.borderSize = _borderSize;
        this.material.size = vec2(width, height);
        this.material.contentScale = 1.0;

        entity.addChild(_content.entity);

        LabelComponent label = new LabelComponent(getShowText(), _borderSize*0.9, _borderColor, Label.Strategy.Center);

        auto opener = new ButtonComponent(label.width, _borderSize, label);
        opener.x = _borderSize;
        opener.y = 0;
        opener.zIndex = 1;
        opener.setDarkColor(vec4(0.3, 0.3, 0.3, 0.5));
        opener.setLightColor(vec4(0.3, 0.3, 0.3, 0.5));
        opener.setBorderColor(vec4(0));
        opener.setBorderSize(0);
        opener.setTrigger({
            _isOpen ^= true;
            opener.setText(getShowText());
        });
        _opener = opener;

        entity.addChild(_opener.entity);

        super(entity, false);
    }

    override float width() {
        return this.material.size.x;
    }

    override float height() {
        return _content.height * _content.entity.obj.scale.y + 2*_borderSize;
    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        move();
        _opener.update(mouse, activeControllable);
        _content.update(mouse, activeControllable);
    }

    private void move() {
        float a = 0.5;
        vec3 target = _isOpen ? vec3(1) : vec3(0);
        _content.entity.obj.scale = a*target + (1 - a)*_content.entity.obj.scale;
        this.material.contentScale = _content.entity.obj.scale.x;
    }

    private dstring getShowText() {
        return (_isOpen ? "△"d : "▽"d) ~ _name;
    }

}
