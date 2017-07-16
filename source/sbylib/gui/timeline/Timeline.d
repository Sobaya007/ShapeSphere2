module sbylib.gui.Timeline;

import sbylib;
import std.range, std.algorithm, std.array;
import std.math;
import std.format;

class Timeline : IControllable {
    alias RectEntity = EntityTemp!(GeometryRect, ColorMaterial);
    alias LinesEntity = EntityTemp!(Lines.GeometryLineGroup, ColorMaterial);

    enum N = 300;

    private Entity root;
    private LinesEntity line;
    private RectEntity rect;
    private float time;
    private int lastWritten;
    private bool firstFlag, secondFlag;
    private void delegate(Mouse2D) control;
    private float[] values;
    private Label maxLabel;
    private Label minLabel;

    this(Font font) {
        this.time = -0.5;
        this.lastWritten = 1;

        this.line = new LinesEntity(Lines.create(N*2));
        line.getMesh().mat.color = vec4(1,0,0,1);

        this.rect = new RectEntity(Rect.create(1,1));
        this.rect.getMesh().mat.color = vec4(0.4);
        this.rect.createCollisionPolygon();
        this.minLabel = new Label(font);
        this.minLabel.obj.pos = vec3(-0.5, -0.5, -0.1);
        this.minLabel.setColor(vec4(1));
        this.minLabel.setOrigin(Label.OriginX.Left, Label.OriginY.Bottom);
        this.minLabel.setSize(0.05);
        this.maxLabel = new Label(font);
        this.maxLabel.obj.pos = vec3(-0.5, +0.5, -0.1);
        this.maxLabel.setColor(vec4(1));
        this.maxLabel.setOrigin(Label.OriginX.Left, Label.OriginY.Top);
        this.maxLabel.setSize(0.05);
        this.root = new Entity;
        this.root.addChild(this.line);
        this.root.addChild(this.rect);
        this.root.addChild(this.minLabel);
        this.root.addChild(this.maxLabel);
        this.root.setUserData(cast(void*)cast(IControllable)this);
    }

    void add(float val) {
        auto v = vec3(-time, val, 0);
        if (!this.firstFlag) {
            this.firstFlag = true;
            this.line.getMesh().geom.vertices[0].position = v;
        } else if (!this.secondFlag) {
            this.secondFlag = true;
            this.line.getMesh().geom.vertices[1].position = v;
        } else {
            auto n1 = (lastWritten + 1) % (N * 2);
            auto n2 = (lastWritten + 2) % (N * 2);
            this.line.geom.vertices[n1].position = this.line.geom.vertices[lastWritten].position;
            this.line.geom.vertices[n2].position = v;
            this.line.geom.updateBuffer();
            this.line.obj.pos = vec3(time-0.5,0,0);
            this.lastWritten = (this.lastWritten + 2) % (N * 2);
        }
        this.time += 1.0f / N;

        import std.algorithm;
        if (this.values.length < N) {
            this.values ~= val;
        } else {
            copy(this.values[1..$], this.values[0..$-1]);
            this.values[$-1] = val;
        }
        auto min = this.values.minElement;
        auto max = this.values.maxElement;
        auto size = max - min;
        size = size < 0.01 ? 0.01 : size;
        this.line.obj.pos.y = -(min + max) / (4 * size);
        this.line.obj.scale.y = 1 / (2 * size);
        this.minLabel.renderText(format!"%.3f"d(min));
        this.maxLabel.renderText(format!"%.3f"d(max));
    }

    void update(Mouse2D mouse) {
        if (this.control) {
            this.control(mouse);
        }
    }

    void translate(Mouse2D mouse) {
        mouse.getDif();
        this.root.obj.pos += vec3(mouse.getDif(), 0);
    }

    override Entity getEntity() {
        return this.root;
    }

    override void onMousePressed(MouseButton button) {
        if (button != MouseButton.Button1) return;
        this.control = &this.translate;
    }

    override void onMouseReleased(MouseButton button) {
        if (button != MouseButton.Button1) return;
        this.control = null;
    }
}
