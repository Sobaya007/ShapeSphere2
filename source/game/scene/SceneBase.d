module game.scene.SceneBase;

import game.scene.SceneTransition;
import sbylib;

interface SceneBase {

    Maybe!SceneTransition step();
}

mixin template SceneBasePack() {
    import game.scene.SceneCallback;

    private SceneCallback[] callbacks;

    public static auto opCall(SceneCallback[] cbs...) {
        auto res = new typeof(this)();
        foreach (cb; cbs) {
            res.addCallbacks(cb);
        }
        return res;
    }

    void addCallbacks(SceneCallback callbacks) {
        this.callbacks ~= callbacks;
    }

    Maybe!SceneTransition opDispatch(string name)() {
        foreach (cb; this.callbacks) {
            if (cb.getName() == name) {
                return Just(cb());
            }
        }
        import std.format;
        assert(false, name.format!"%s is not a callback name.");
    }

}
