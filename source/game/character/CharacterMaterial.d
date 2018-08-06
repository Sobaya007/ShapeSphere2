module game.character.CharacterMaterial;

import sbylib;

class CharacterMaterial : Material {
    mixin ConfigureMaterial;

    this() {
        mixin(autoAssignCode);
        super();
        initialize();
    }
}
