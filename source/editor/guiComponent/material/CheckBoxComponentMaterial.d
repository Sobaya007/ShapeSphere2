module editor.guiComponent.material.CheckBoxComponentMaterial;

import sbylib;

class CheckBoxComponentMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 backColor;
    uvec4 foreColor;
    ubool isChecked;

    void constructor() {
        this.backColor = new uvec4("backColor");
        this.foreColor = new uvec4("foreColor");
        this.isChecked = new ubool("isChecked");
    }
}

alias CheckBoxComponentMaterial = MaterialTemp!CheckBoxComponentMaterialUniformKeeper;
