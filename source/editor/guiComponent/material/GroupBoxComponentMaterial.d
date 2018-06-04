module editor.guiComponent.material.GroupBoxComponentMaterial;

import sbylib;

class GroupBoxComponentMaterial : Material {

    mixin ConfigureMaterial;

    uvec4 borderColor;
    uvec2 size;
    ufloat borderSize;
    ufloat contentScale;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
