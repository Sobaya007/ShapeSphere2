module editor.guiComponent.material.GroupBoxComponentMaterial;

import sbylib;

class GroupBoxComponentMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 borderColor;
    uvec2 size;
    ufloat borderSize;
    ufloat contentScale;

    void constructor() {
        this.borderColor = new uvec4("borderColor");
        this.size        = new uvec2("size");
        this.borderSize  = new ufloat("borderSize");
        this.contentScale = new ufloat("contentScale");
    }
}

alias GroupBoxComponentMaterial = MaterialTemp!GroupBoxComponentMaterialUniformKeeper;
