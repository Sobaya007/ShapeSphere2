module game.scene.Scene;

import std.variant;
import std.traits;
import std.array;
import sbylib;

interface SceneBase {

    Maybe!SceneTransition step();
}

mixin template DeclareCallbacks() {
    private SceneCallback finish;
    private SceneCallback stable;
    private SceneCallback yes;
    private SceneCallback no;
}

mixin template SetCallbacks() {
    void setCallbacks(SceneCallback[] callbacks) {
        import std.algorithm;
        foreach (cb; callbacks) {
            if (cast(OnFinish)cb) {
                this.finish = cb;
            }
            //cb.castSwitch!(
               //(OnFinish c) {}
               //(OnStable c) => this.stable = c,
               //(OnYes c)    => this.yes    = c,
               //(OnNo c)     => this.no     = c,
            //);
        }
    }
}

class SceneInfo {
    private Variant[string] ditionary;

    Maybe!T get(T)(string key) {
        if (key in this.dictionary) {
            return Just(cast(T)this.dictionary[key]);
        } else {
            return None!T;
        }
    }
}

class SceneManager {
static:
    private SceneBase[] scenes;
    private SceneBase[] currentScene;

    void define(SceneBase[] scenes...) {
        SceneManager.scenes ~= scenes;
    }

    void launch(SceneClass)() if (is(SceneClass : SceneBase)) {
        currentState = SceneState.Running;
        currentScene = scenes.filter!(s => cast(SceneClass)s !is null).array;
    }

    void run() {
        while (true) {
            Maybe!SceneTransition tr;
            foreach (s; currentScene) {
                tr = s.step();
            }

            if (tr.isNone) continue;
            tr.get()(currentScene);
        }
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

interface SceneCallback {
    Maybe!SceneTransition opCall();
}

class OnFinish : SceneCallback {

    private SceneTransition transit;

    this(SceneTransition transit) {
        this.transit = transit;
    }

    override Maybe!SceneTransition opCall() {
        return Just(this.transit);
    }
}

SceneCallback onFinish(SceneTransition transit) {
    return new OnFinish(transit);
}

//SceneCallback onStable(SceneTransition transit) {
//
//}
//
//SceneCallback onYes(SceneTransition transit) {
//}
//
//SceneCallback onNo(SceneTransition transit) {
//}

interface SceneTransition {
    void opCall(ref SceneBase[]);
}

class MoveTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneClass)) {

    override void opCall(ref SceneBase[] scenes) {
        scenes = [SceneManager.find!SceneClass.get];
    }
}

class OverTransition(SceneClass) : SceneTransition if (is(SceneClass : SceneClass)) { 
    override void opCall(ref SceneBase[] scenes) {
        scenes ~= SceneManager.find!SceneClass.get;
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

SceneTransition over(SceneClass)(SceneCallback[] callbacks...) if (is(SceneClass : SceneBase)) {
    SceneManager.define(SceneClass(callbacks));
    return new OverTransition!SceneClass;
}

SceneTransition pop() {
    return new PopTransition;
}
