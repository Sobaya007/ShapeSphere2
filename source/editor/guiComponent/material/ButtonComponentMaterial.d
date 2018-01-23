module editor.guiComponent.material.ButtonComponentMaterial;

import sbylib;

class ButtonComponentMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 darkColor;
    uvec4 lightColor;
    uvec4 borderColor;
    ufloat value; // ∈ [0, 1]
    uvec2 size;
    ufloat borderSize;

    void constructor() {
        this.darkColor   = new uvec4("darkColor");
        this.lightColor  = new uvec4("lightColor");
        this.borderColor = new uvec4("borderColor");
        this.value       = new ufloat("value");
        this.size        = new uvec2("size");
        this.borderSize  = new ufloat("borderSize");
    }
}

alias ButtonComponentMaterial = MaterialTemp!ButtonComponentMaterialUniformKeeper;
