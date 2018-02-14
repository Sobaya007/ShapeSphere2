module game.scene.SceneBase;

public import game.scene.manager;
import sbylib;
import std.stdio;

class SceneProtoType : SceneBase {
    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;
    protected World world;
    protected Camera camera;

    this() {
        this(new OrthoCamera(2, 2, -1, 1));
    }

    this(Camera camera) {
        this.state = State.Waiting;
        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 1;

        this.world = new World;
        this.camera = camera;
        this.viewport = new AutomaticViewport(Core().getWindow);

        this.world.setCamera(this.camera);

        this.addEntity(this.fadeRect);
    }

    override void render() {
        this.renderer.render(this.world, this.screen, this.viewport);
    }

    IAnimation fade(AnimSetting!vec4 setting) {
        return new Animation!vec4((color) {
            this.fadeRect.color = color;
        }, setting);
    }

    void addEntity(Entity entity) {
        this.world.add(entity);
    }
}

class SceneBase {

    enum State {Waiting, Running, Finished};

    protected Maybe!FinishCallback _finish;
    protected Maybe!SelectCallback _select;
    protected Renderer renderer;
    protected Screen screen;
    protected IViewport viewport;
    private State state;
    public Maybe!SceneTransition transition;

    struct Event {
        bool delegate() trigger;
        void delegate() content;
    }
    Event[] events;

    this() {
        auto window = Core().getWindow();
        this.screen = window.getScreen;
        this.renderer = new Renderer;
    }

    void initialize() {
        this.state = State.Running;
        this.transition = None!SceneTransition;
    }

    void clear() {
        this.screen.clear(ClearMode.Color, ClearMode.Depth);
    }

    abstract void render();

    void step(bool eventAccept) {
        this.render();
        if (eventAccept) {
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

    void addEvent(bool delegate() trigger, void delegate() content) {
        this.events ~= Event(trigger, content);
    }

}

mixin template SceneBasePack() {

    import game.scene.manager.SceneCallback;
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
