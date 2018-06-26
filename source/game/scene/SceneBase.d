module game.scene.SceneBase;

public import game.scene.manager;
import sbylib;
import std.stdio;

class SceneProtoType : SceneBase {
    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;
    protected World world;
    protected Camera camera;
    protected Renderer renderer;

    this() {
        this(new OrthoCamera(2, 2, -1, 1));
    }

    this(OrthoCamera camera) {
        this.state = State.Waiting;
        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 1;
        this.fadeRect.name = "Fade Rect";

        this.world = new World;
        this.camera = camera;
        this.viewport = new AspectFixViewport(Core().getWindow);

        this.world.setCamera(this.camera);

        this.addEntity(this.fadeRect);

        Core().getWindow().addResizeCallback({
            camera.width = camera.height * viewport.getWidth() / viewport.getHeight();
            fadeRect.scale.x = cast(float)viewport.getWidth() / viewport.getHeight();
        });

        this.renderer = new Renderer(this.world, this.screen, this.viewport);
    }

    override void render() {
        this.renderer.render();
    }

    auto fade(AnimSetting!vec4 setting) {
        return animation((vec4 color) {
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
    protected Screen screen;
    private State state;
    public Maybe!SceneTransition transition;
    public IViewport viewport;

    struct Event {
        bool delegate() trigger;
        void delegate() content;
    }
    Event[] events;

    this() {
        auto window = Core().getWindow();
        this.screen = window.getScreen;
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
