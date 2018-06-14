module sbylib.gui.Timeline;

import sbylib;
import std.range, std.algorithm;
import std.math;
import std.format;

class Timeline : IControllable {
    alias RectEntity = TypedEntity!(GeometryRect, ColorMaterial);
    alias LinesEntity = TypedEntity!(Lines.GeometryLineGroup, ColorMaterial);

    enum N = 300;

    private Entity root;
    private LinesEntity line;
    private RectEntity rect;
    private float time;
    private int lastWritten;
    private bool firstFlag, secondFlag;
    private void delegate(ViewportMouse) control;
    private float[] values;
    private Label maxLabel;
    private Label minLabel;

    this() {
        this.time = -0.5;
        this.lastWritten = 1;

        this.line = makeEntity(Lines.create(N*2), new ColorMaterial);
        line.color = vec4(1,0,0,1);

        this.rect = makeEntity(Rect.create(1,1), new ColorMaterial);
        this.rect.color = vec4(0.4);
        this.rect.buildBVH();
        LabelFactory factory;
        factory.fontName = "HGRPP1.TTC";
        factory.height = 0.05;
        factory.textColor = vec4(1);
        factory.strategy = Label.Strategy.Left;

        this.minLabel = factory.make();
        this.minLabel.left = -0.5;
        this.minLabel.bottom = -0.5;
        this.minLabel.pos.z = -0.1;

        this.maxLabel = factory.make();
        this.maxLabel.left = -0.5;
        this.maxLabel.top  = +0.5;
        this.maxLabel.pos.z = -0.1;

        this.root = new Entity;
        this.root.addChild(this.line);
        this.root.addChild(this.rect);
        this.root.addChild(this.minLabel);
        this.root.addChild(this.maxLabel);
        this.root.setUserData("controllable", cast(IControllable)this);
    }

    void add(float val) {
        auto v = vec3(-time, val, 0);
        if (!this.firstFlag) {
            this.firstFlag = true;
            this.line.geom.vertices[0].position = v;
        } else if (!this.secondFlag) {
            this.secondFlag = true;
            this.line.geom.vertices[1].position = v;
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

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        if (this.control) {
            this.control(mouse);
        }
    }

    void translate(ViewportMouse mouse) {
        this.root.obj.pos += vec3(mouse.dif, 0);
    }

    override Entity entity() {
        return this.root;
    }

    override void onMousePressed(MouseButton button) {
        if (button != MouseButton.Button1) return;
        this.control = &this.translate;
    }

    override void onMouseReleased(MouseButton button, bool isCollided) {
        if (button != MouseButton.Button1) return;
        this.control = null;
    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {
    }
    override void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed) {
    }

}
