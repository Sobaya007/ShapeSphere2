module sbylib.material.ExpandMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

class ExpandMaterial(OriginalMaterial, ExpandedRegionMaterial) : Material {
    enum MaterialName1 = "OriginalMaterial";
    enum MaterialName2 = "ExpandedRegionMaterial";

    mixin ConfigureMixMaterial!(OriginalMaterial, ExpandedRegionMaterial,
    q{
{
    "useGeometryShader" : true
}
    });

    private ubool expand;
    ufloat expandScale;

    this() {
        mixin(autoAssignCode);
        initialize();
        super();

        this.expandScale = 1.1;

        this.process = (void delegate() render) {
            this.faceMode = FaceMode.Front;
            this.expand = false;
            render();

            this.faceMode = FaceMode.Back;
            this.expand = true;
            render();
        };
    }
}

