module game.scene.SceneTransition;

import game.scene.SceneBase;
import game.scene.SceneCallback;
import game.scene.SceneManager;
import std.stdio;

interface SceneTransition {
    void opCall(ref SceneBase[]);
}

class MoveTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneBase)) {

    override void opCall(ref SceneBase[] scenes) {
        auto newScene = SceneManager.find!SceneClass.get;
        newScene.initialize();
        scenes = [newScene];
    }
}

class OverTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneBase)) { 
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

SceneTransition move(SceneClass)() if (is(SceneClass : SceneBase)) {
    return new MoveTransition!SceneClass;
}

SceneTransition over(SceneClass)() if (is(SceneClass : SceneBase)) {
    return new OverTransition!SceneClass;
}

SceneTransition move(SceneClass,Callbacks...)(Callbacks callbacks) 
    if (is(SceneClass : SceneBase)) {
    SceneManager.define(SceneClass(callbacks));
    return new MoveTransition!SceneClass;
}

SceneTransition over(SceneClass,Callbacks...)(Callbacks callbacks) 
    if (is(SceneClass : SceneBase)) {
    SceneManager.define(SceneClass(callbacks));
    return new OverTransition!SceneClass;
}

SceneTransition pop() {
    return new PopTransition;
}
