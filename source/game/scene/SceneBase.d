module game.scene.SceneBase;

import game.scene.SceneTransition;
import game.scene.SceneCallback;
public import game.scene.AnimationSet;
import sbylib;


class SceneBase {

    private SceneCallback[] callbacks;
    private EntityTemp!(GeometryRect, ColorMaterial) fadeRect;
    private Maybe!AnimationSet animationSet;
    private World world;
    private Camera camera;
    private Renderer renderer;
    private Screen screen;
    private IViewport viewport;

    this() {
        this.fadeRect = ColorEntity(2,2);
        this.fadeRect.getMesh().mat.color = vec4(0);
        this.fadeRect.getMesh().mat.config.transparency = true;
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

    this(AnimationSet animationSet) {
        this.animationSet = Just(animationSet);
        animationSet.setScene(this);
        this();
    }

    void initialize() {
        this.animationSet.apply!(set => set.initialize());
    }

    void render() {
        this.screen.clear(ClearMode.Color, ClearMode.Depth);
        this.renderer.render(this.world, this.screen, this.viewport);
    }

    Maybe!SceneTransition step() {
        this.render();
        return animationSet.fmapAnd!((AnimationSet set) => set.step());
    }

    void addCallbacks(SceneCallback callbacks) {
        this.callbacks ~= callbacks;
    }

    SceneTransition opDispatch(string name)() {
        foreach (cb; this.callbacks) {
            if (cb.getName() == name) {
                return cb();
            }
        }
        import std.format;
        assert(false, format!"%s's %s is not a callback name."(typeid(this),name));
    }

    IAnimation fade(AnimSetting!vec4 setting) {
        return new Animation!vec4((color) {
            this.fadeRect.getMesh.mat.color = color;
        }, setting);
    }

    void addEntity(Entity entity) {
        this.world.add(entity);
    }

}

mixin template SceneBasePack() {

    import game.scene.SceneCallback;
    public static auto opCall(SceneCallback[] cbs...) {
        auto res = new typeof(this)();
        foreach (cb; cbs) {
            res.addCallbacks(cb);
        }
        return res;
    }
}
