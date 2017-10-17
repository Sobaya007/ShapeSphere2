module sbylib.material.UniformKeeper;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.utils.Lazy;

abstract class UniformKeeper {

    abstract Lazy!Uniform[] getUniforms();
}
