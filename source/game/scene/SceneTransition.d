module game.scene.SceneTransition;

import game.scene.SceneBase;
import game.scene.SceneCallback;
import game.scene.SceneManager;

interface SceneTransition {
    void opCall(ref SceneBase[]);
}

class MoveTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneClass)) {

    override void opCall(ref SceneBase[] scenes) {
        auto newScene = SceneManager.find!SceneClass.get;
        newScene.initialize();
        scenes = [newScene];
    }
}

class OverTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneClass)) { 
    override void opCall(ref SceneBase[] scenes) {
        auto newScene = SceneManager.find!SceneClass.get;
        newScene.initialize();
        scenes ~= newScene;
    }
}

class PopTransition : SceneTransition {

    override void opCall(ref SceneBase[] scenes) {
        scenes = scenes[0..$-1];
    }
}

SceneTransition move(SceneClass)(SceneCallback[] callbacks...) if (is(SceneClass : SceneBase)) {
    if (callbacks.length > 0) {
        SceneManager.define(SceneClass(callbacks));
    }
    return new MoveTransition!SceneClass;
}

SceneTransition over(SceneClass)(SceneCallback[] callbacks...) if (is(SceneClass : SceneBase)) {
    if (callbacks.length > 0) {
        SceneManager.define(SceneClass(callbacks));
    }
    return new OverTransition!SceneClass;
}

SceneTransition pop() {
    return new PopTransition;
}
