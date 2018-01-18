module game.stage.StageMaterial;

import sbylib;

class StageMaterial : PhongTextureMaterial {

    private string matName;

    this(string matName) {
        this.matName = matName;
        super();
    }

    string getName() {
        return this.matName;
    }
}
