module sbylib.utils.Unit;

import std.typecons;

mixin template GenerateUnit(string Struct, string Function, BaseType) {
    import std.format;
    mixin(format!q{
        struct %s {
            %s value;
            alias value this;

            auto opBinary(string op)(typeof(this) other) {
                return typeof(this)(mixin("this.value "~op~" other.value"));
            }

            auto opBinary(string op)(%s other) {
                return typeof(this)(mixin("this.value "~op~" other"));
            }
        }

        %s %s(%s value) { return %s(value); }
    }(Struct, BaseType.stringof, BaseType.stringof,
        Struct, Function, BaseType.stringof, Struct));
}

mixin GenerateUnit!("Frame", "frame", long);
mixin GenerateUnit!("Pixel", "pixel", float);
