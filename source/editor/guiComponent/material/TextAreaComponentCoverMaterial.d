module editor.guiComponent.material.TextAreaComponentCoverMaterial;

import sbylib;

class TextAreaComponentCoverMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    ufloat opacity;
    uvec4 color;

    void constructor() {
        this.opacity = new ufloat("opacity");
        this.color   = new uvec4("color");
    }
}

alias TextAreaComponentCoverMaterial = MaterialTemp!TextAreaComponentCoverMaterialUniformKeeper;
