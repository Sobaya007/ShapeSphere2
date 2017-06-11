module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.gl.Uniform;
import sbylib.utils.Watcher;
import sbylib.setting;

class LambertMaterial : Material {
    enum VERT_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.vert";
    enum FRAG_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.frag";
    this(Watcher!(umat4) worldMatrix, Watcher!(umat4) viewMatrix, Watcher!(umat4) projMatrix) {
        const shader = MaterialUtils.createProgramFromPath(VERT_ROOT, FRAG_ROOT);
        super(shader, worldMatrix, viewMatrix, projMatrix);
    }
}
