module sbylib.material.UniformKeeper;

public import sbylib.wrapper.gl.Uniform;

abstract class UniformKeeper {

    abstract const(Uniform) delegate()[] getUniforms();
}
