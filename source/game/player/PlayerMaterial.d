module game.player.PlayerMaterial;

import sbylib;

class PlayerMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;
}

alias PlayerMaterial = MaterialTemp!PlayerMaterialUniformKeeper;
