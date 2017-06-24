module sbylib.material.UniformKeeper;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

abstract class UniformKeeper {

    abstract Uniform[] getUniforms();
}
