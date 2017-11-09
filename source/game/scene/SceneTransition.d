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
        auto newScene = SceneManager.find!SceneClass;
        newScene.initialize();
        scenes ~= newScene;
    }
}

class PopTransition : SceneTransition {

    override void opCall(ref SceneBase[] scenes) {
        scenes = scenes[0..$-1];
    }
}

SceneTransition move(SceneClass)() if (is(SceneClass : SceneBase)) {
    return new MoveTransition!SceneClass;
}

SceneTransition over(SceneClass)() if (is(SceneClass : SceneBase)) {
    return new OverTransition!SceneClass;
}

SceneTransition move(SceneClass)(FinishCallback callback) if (is(SceneClass : SceneBase)) {
    SceneManager.define(SceneClass(callback));
    return new MoveTransition!SceneClass;
}

SceneTransition pop() {
    return new PopTransition;
}
