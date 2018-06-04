module game.player.PlayerMaterial;

import sbylib;

class PlayerMaterial : Material {

    mixin ConfigureMaterial;

    this() {
        initialize();
    }
}
