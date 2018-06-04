module game.stage.crystalMine.CrystalMaterial;

import sbylib;
import game.Game;

class CrystalMaterial : Material {

    mixin ConfigureMaterial;

    private utexture backBuffer;
    private RenderTarget buffer;

    this() {
        mixin(autoAssignCode);
        super();

        this.backBuffer = Game.getBackBuffer().getColorTexture();
        this.config.renderGroupName = "Crystal";
    }
}
