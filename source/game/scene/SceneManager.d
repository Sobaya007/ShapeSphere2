module game.scene.SceneManager;

import game.scene.SceneBase;
import game.scene.SceneTransition;
import sbylib;
import std.stdio;

class SceneManager {
static:
    private SceneBase[] scenes;
    private SceneBase[] currentScene;

    void define(SceneBase[] scenes...) {
        SceneManager.scenes ~= scenes;
    }

    void launch(SceneClass)() if (is(SceneClass : SceneBase)) {
        import std.algorithm;
        import std.array;
        currentScene = scenes.filter!(s => cast(SceneClass)s !is null).array;
        currentScene.each!(scene => scene.initialize());
        Core().addProcess(&this.run, "SceneManager.run");
    }

    void run() {
        Maybe!SceneTransition tr;
        currentScene[0].clear();
        foreach (i, s; currentScene) {
            s.step(i == currentScene.length-1);
            if (tr.isJust) continue;
            tr = s.transition.take();
        }

        if (tr.isNone) return;
        tr.get()(currentScene);
    }

    Maybe!SceneBase find(SceneClass)() if (is(SceneClass : SceneBase)) {
        foreach (s; scenes) {
            if (cast(SceneClass)s) {
                return Just(s);
            }
        }
        return None!SceneBase;
    }
}
