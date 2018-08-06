module sbylib.material.ShaderMaterial;

import sbylib.material.Material;

class ShaderMaterial(string configStr="{}") : Material {

    mixin ConfigureMaterial!(configStr);

    private Uniform[string] uniformList;

    template opDispatch(string mem) {

        import std.format;
        import std.traits;
        import sbylib.utils.Maybe;
        import sbylib.material.RenderConfig;

        static if (__traits(hasMember, RenderConfig, mem)) {
            auto opDispatch(T)(T val) {
                return mixin("config."~mem~"=val");
            }
        } else {
            auto opDispatch(T)(T val) {
                if (mem in this.uniformList) {
                    this.uniformList[mem]
                        .wrapCast!(TypedUniform!(T))
                        .getOrError(format!("type of '%s' is not %s")(mem, T.stringof))
                        = val;
                }
                else this.uniformList[mem] = createUniform(val, mem);
                return val;
            }

            auto opDispatch(T)() {
                return this.uniformList.at(mem).getOrError(format!("'%s' is not assigned")(mem))
                    .wrapCast!(TypedUniform!(T)).getOrError(format!("type of '%s' is not %s")(mem, T.stringof));
            }
        }
    }

    this() {
        mixin(autoAssignCode);
        super();
    }
}
