module game.stage.crystalMine.CrystalMaterial;

import sbylib;
import game.Game;

class CrystalMaterial : Material {

    mixin declare;

    private utexture backBuffer;
    private RenderTarget buffer;

    this() {
        mixin(autoAssignCode);
        super();


        this.backBuffer = Game.getBackBuffer().getColorTexture();
        this.config.renderGroupName = "Crystal";
    }
}
