module game.character.CharacterMaterial;

import sbylib;

class CharacterMaterial : Material {
    mixin ConfigureMaterial;

    this() {
        initialize();
    }
}
