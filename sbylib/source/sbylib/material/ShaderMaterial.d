module sbylib.material.ShaderMaterial;

import sbylib.material.Material;

class ShaderMaterial(string configStr="{}") : Material {

    mixin ConfigureMaterial!(configStr);

    private Uniform[] uniformList;

    auto opDispatch(string op, T)(T val) {
        this.uniformList ~= createUniform(val, op);
        return val;
    }
}
