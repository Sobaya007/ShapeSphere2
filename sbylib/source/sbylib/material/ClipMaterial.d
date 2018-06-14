module sbylib.material.ClipMaterial;

import sbylib;

class ClipMaterial(Material1, Material2) : Material {

    enum MaterialName1 = "Material1";
    enum MaterialName2 = "Material2";

    mixin ConfigureMixMaterial!(Material1, Material2);

    enum Shape {
        Circle,
    }

    TypedUniform!(int) shape;


    this() {
        mixin(autoAssignCode);
        initialize();
        super();

        this.shape = Shape.Circle;
    }
}
