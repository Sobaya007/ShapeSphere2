module editor.guiComponent.material.TextAreaComponentMaterial;

import sbylib;

class TextAreaComponentMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 borderColor;
    uvec4 backgroundColor;
    uvec2 size;
    ufloat borderSize;

    void constructor() {
        this.borderColor     = new uvec4("borderColor");
        this.backgroundColor = new uvec4("backgroundColor");
        this.size            = new uvec2("size");
        this.borderSize      = new ufloat("borderSize");
    }
}

alias TextAreaComponentMaterial = MaterialTemp!TextAreaComponentMaterialUniformKeeper;
