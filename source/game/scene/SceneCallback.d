module game.scene.SceneCallback;

import game.scene.SceneTransition;

class SceneCallback {
    private string name;
    private SceneTransition transit;
    this(string name, SceneTransition transit) {
        this.name = name;
        this.transit = transit;
    }

    SceneTransition opCall() {
        return this.transit;
    }

    string getName() {
        return this.name;
    }
}

SceneCallback onFinish(SceneTransition transit) {
    return new SceneCallback("finish", transit);
}

SceneCallback onStable(SceneTransition transit) {
    return new SceneCallback("stable", transit);
}

SceneCallback onYes(SceneTransition transit) {
    return new SceneCallback("yes", transit);
}

SceneCallback onNo(SceneTransition transit) {
    return new SceneCallback("no", transit);
}
