module game.character.CharacterMaterial;

import sbylib;

class CharacterMaterialUniformKeeper : UniformKeeper {
    mixin MaterialUtils.declare;
}

alias CharacterMaterial = MaterialTemp!CharacterMaterialUniformKeeper;
