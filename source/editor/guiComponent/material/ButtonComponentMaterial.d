module editor.guiComponent.material.ButtonComponentMaterial;

import sbylib;

class ButtonComponentMaterial : Material {

    mixin declare;

    uvec4 darkColor;
    uvec4 lightColor;
    uvec4 borderColor;
    ufloat value; // ∈ [0, 1]
    uvec2 size;
    ufloat borderSize;

    this() {

        mixin(autoAssignCode);
        super();
    }
}
