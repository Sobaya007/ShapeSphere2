module sbylib.gui.Timeline;

import sbylib;
import std.range, std.algorithm, std.array;
import std.math;
import std.format;

class Timeline : IControllable {
    alias RectMesh = MeshTemp!(GeometryRect, ColorMaterial, Object3DS);
    alias LinesMesh = MeshTemp!(Lines.GeometryLineGroup, ColorMaterial, Object3DS);

    enum N = 300;

    MeshGroup mesh;
    private LinesMesh line;
    private RectMesh rect;
    private float time;
    private int lastWritten;
    private bool firstFlag, secondFlag;
    private void delegate(Mouse2D) control;
    private float[] values;
    private Label maxLabel;
    private Label minLabel;

    this(Font font) {
        this.line = new LinesMesh(Lines.create(N*2));
        this.line.mat.color = vec4(1,0,0,1);
        this.rect = new RectMesh(Rect.create(1,1));
        this.rect.mat.color = vec4(0.4);
        this.time = -0.5;
        this.lastWritten = 1;
        this.rect.createCollisionPolygons();
        this.rect.geom.getCollisionPolygons().setUserData(cast(void*)cast(IControllable)this);
        this.minLabel = new Label(font);
        this.minLabel.mesh.obj.pos = vec3(-0.5, -0.5, -0.1);
        this.minLabel.setColor(vec4(1));
        this.minLabel.setOrigin(Label.OriginX.Left, Label.OriginY.Bottom);
        this.minLabel.setSize(0.05);
        this.maxLabel = new Label(font);
        this.maxLabel.mesh.obj.pos = vec3(-0.5, +0.5, -0.1);
        this.maxLabel.setColor(vec4(1));
        this.maxLabel.setOrigin(Label.OriginX.Left, Label.OriginY.Top);
        this.maxLabel.setSize(0.05);
        this.mesh = new MeshGroup;
        this.mesh.add(this.line);
        this.mesh.add(this.rect);
        this.mesh.add(this.minLabel.mesh);
        this.mesh.add(this.maxLabel.mesh);
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

    void update(Mouse2D mouse) {
        if (this.control) {
            this.control(mouse);
        }
    }

    void translate(Mouse2D mouse) {
        this.mesh.obj.pos += vec3(mouse.getDif(), 0);
    }

    override ICollidable getCollidable() {
        return this.rect.geom.getCollisionPolygons();
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
