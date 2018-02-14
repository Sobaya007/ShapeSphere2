module editor.guiComponent.material.CheckBoxComponentMaterial;

import sbylib;

class CheckBoxComponentMaterial : Material {

    mixin declare;

    uvec4 backColor;
    uvec4 foreColor;
    ubool isChecked;

    this() {

        mixin(autoAssignCode);
        super();

    }
}
