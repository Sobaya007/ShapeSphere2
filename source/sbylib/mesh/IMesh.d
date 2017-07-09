module sbylib.mesh.IMesh;

public {
    import sbylib.wrapper.gl.Uniform;
    import sbylib.material.glsl.UniformDemand;
    import sbylib.core.Bahamut;
    import sbylib.mesh.Object3D;
}

interface IMesh {
    void render();
    void resolveEnvironment(Bahamut);
    void setParent(Object3D);
}
