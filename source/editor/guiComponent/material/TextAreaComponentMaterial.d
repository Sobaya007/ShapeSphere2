module editor.guiComponent.material.TextAreaComponentMaterial;

import sbylib;

class TextAreaComponentMaterial : Material {

    mixin declare;

    uvec4 borderColor;
    uvec4 backgroundColor;
    uvec2 size;
    ufloat borderSize;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
