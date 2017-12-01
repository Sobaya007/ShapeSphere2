module game.scene.SceneBase;

import game.scene.SceneTransition;
import game.scene.SceneCallback;
import sbylib;
import std.stdio;

class SceneBase {

    enum State {Waiting, Running, Finished};

    protected Maybe!FinishCallback _finish;
    protected Maybe!SelectCallback _select;
    private EntityTemp!(GeometryRect, ColorMaterial) fadeRect;
    private World world;
    private Camera camera;
    private Renderer renderer;
    private Screen screen;
    private IViewport viewport;
    private State state;
    public Maybe!SceneTransition transition;

    struct Event {
        bool delegate() trigger;
        void delegate() content;
    }
    Event[] events;

    this() {
        this.state = State.Waiting;
        this.fadeRect = ColorEntity(vec4(0), 2,2);
        this.fadeRect.getMesh().mat.config.transparency = true;
        this.fadeRect.getMesh().mat.config.depthWrite = false;
        this.fadeRect.pos.z = 1;

        auto window = Core().getWindow();
        this.world = new World;
        this.camera = new OrthoCamera(2,2,-1,1);
        this.renderer = new Renderer;
        this.screen = window.getScreen;
        this.viewport = new AutomaticViewport(window);

        this.world.setCamera(this.camera);

        this.addEntity(this.fadeRect);
    }

    void initialize() {
        this.state = State.Running;
        this.transition = None!SceneTransition;
    }

    void clear() {
        this.screen.clear(ClearMode.Color, ClearMode.Depth);
    }

    void render() {
        this.renderer.render(this.world, this.screen, this.viewport);
    }

    void step(bool isTop) {
        this.render();
        if (isTop) {
            foreach (event; this.events) {
                if (event.trigger()) {
                    event.content();
                }
            }
        }
    }

    void finish() in {
        import std.format;
        assert(this._finish.isJust, format!"%s don't have 'finish'"(typeid(this)));
    } body {
        this.transition = Just(this._finish.get()());
        this.state = State.Finished;
    }

    void select(size_t idx) in {
        import std.format;
        //assert(this._select.isJust, format!"%s don't have 'select'"(typeid(this)));
    } body {
        import std.stdio;
        this.transition = Just(this._select.get()(idx));
        this.state = State.Finished;
    }

    IAnimation fade(AnimSetting!vec4 setting) {
        return new Animation!vec4((color) {
            this.fadeRect.getMesh.mat.color = color;
        }, setting);
    }

    void addEntity(Entity entity) {
        this.world.add(entity);
    }

    void addEvent(bool delegate() trigger, void delegate() content) {
        this.events ~= Event(trigger, content);
    }

}

mixin template SceneBasePack() {

    import game.scene.SceneCallback;
    public static auto opCall(FinishCallback finish) {
        auto res = new typeof(this)();
        res._finish = Just(finish);
        return res;
    }

    public static auto opCall(SelectCallback select) {
        auto res = new typeof(this)();
        res._select = Just(select);
        return res;
    }
}
