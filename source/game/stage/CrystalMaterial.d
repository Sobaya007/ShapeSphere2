module game.stage.CrystalMaterial;

import sbylib;

class CrystalMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;
}

alias CrystalMaterial = MaterialTemp!(CrystalMaterialUniformKeeper);
