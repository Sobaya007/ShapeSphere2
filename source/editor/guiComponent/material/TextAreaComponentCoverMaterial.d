module editor.guiComponent.material.TextAreaComponentCoverMaterial;

import sbylib;

class TextAreaComponentCoverMaterial : Material {

    mixin declare;

    ufloat opacity;
    uvec4 color;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
