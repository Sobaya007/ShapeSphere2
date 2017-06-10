module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.gl.Uniform;
import sbylib.utils.Watcher;

class LambertMaterial : Material {
    this(uniformMat4fw worldMatrix, uniformMat4fw viewMatrix, uniformMat4fw projMatrix) {
        super(shader, worldMatrix, viewMatrix, projMatrix);
    }
}
