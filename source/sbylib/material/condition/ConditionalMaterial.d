module sbylib.material.ConditionalMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class ConditionalMaterialUniformMaterial(TrueMaterial, FalseMaterial) : UniformKeeper {

    enum MaterialName1 = "TrueMaterial";
    enum MaterialName2 = "FalseMaterial";

    mixin MaterialUtils.declareMix!(TrueMaterial, FalseMaterial);

    ubool condition;
    private TrueMaterial.Keeper trueKeeper;
    private FalseMaterial.Keeper falseKeeper;

    void constructor(Material mat) {
        import std.string;
        this.trueKeeper = new TrueMaterial.Keeper(mat, s => MaterialName1 ~ capitalize(s));
        this.falseKeeper = new FalseMaterial.Keeper(mat, s => MaterialName2 ~ capitalize(s));
        this.condition = new ubool("condition");
    }

    ref auto opDispatch(string s)() {
        static if (__traits(hasMember, trueKeeper, s)) {
            return mixin("trueKeeper." ~ s);
        } else static if (__traits(hasMember, falseKeeper, s)) {
            return mixin("falseKeeper." ~ s);
        } else {
            static assert(false);
        }
    }

    override Uniform[] getUniforms() {
        return [condition];
    }
}

alias ConditionalMaterial(TrueMaterial, FalseMaterial) = MaterialTemp!(ConditionalMaterialUniformMaterial!(TrueMaterial, FalseMaterial));
