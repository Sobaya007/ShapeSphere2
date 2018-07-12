module sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.wrapper.gl.Texture;

alias ubool = TypedUniform!(bool);
alias ufloat = TypedUniform!(float);
alias uvec2 = TypedUniform!(vec2);
alias uvec3 = TypedUniform!(vec3);
alias uvec4 = TypedUniform!(vec4);
alias umat4 = TypedUniform!(mat4);
alias utexture = TypedUniform!(Texture);

interface Uniform {

    import sbylib.wrapper.gl.Program;

    string getName() const;
    void setName(string);
    void apply(const Program, ref uint, ref uint) const;
}

auto createUniform(T)(T val, string name) if (isAcceptable!(T)) {
    return new TypedUniform!(T)(name, val);
}

private template isAcceptable(T) {
    import std.traits : isInstanceOf;

    static if (is(T == bool) || is(T == int) || is(T == float) || is(T == Texture)) {
        enum isAcceptable = true;
    } else static if (isInstanceOf!(Vector, T)) {
        enum isAcceptable = isAcceptable!(T.ElementType) && 1 <= T.Dimension && T.Dimension <= 4;
    } else static if(isInstanceOf!(Matrix, T)) {
        enum isAcceptable = isAcceptable!(T.ElementType) && 1 <= T.Row && 1 <= T.Column && T.Row <= 4 && T.Column <= 4 && T.Row == T.Column;
    } else {
        enum isAcceptable = false;
    }
}

class TypedUniform(Type) : Uniform
    if (isAcceptable!(Type)) {

    import sbylib.wrapper.gl.Program;

    string name;
    Type value;

    this(string name) {
        this.name = name;
    }

    this(string name, Type value) {
        this.name = name;
        this = value;
    }

    auto opAssign(Type value) {
        this.value = value;
        return value;
    }

    auto opUnary(string op)() {
        return mixin("this.value" ~ op);
    }

    auto opBinary(string op, T)(auto ref T value) const {
        return mixin("this.value " ~ op ~ "value");
    }

    auto opOpAssign(string op, T)(auto ref T value) {
        return mixin("this.value " ~ op ~ "= value");
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const {
        import sbylib.wrapper.gl.Functions;
        import std.traits : isInstanceOf;

        auto loc = this.getLocation(program);
        static if (is(Type == Texture)) {
            assert(this.value !is null, "UniformTexture's value is null");
            Texture.activate(textureUnit);
            this.value.bind();
            GlUtils.uniform!(int)(loc, textureUnit);
            textureUnit++;
        } else static if (isInstanceOf!(Vector, Type)) {
            GlUtils.uniform!(Type.ElementType, Type.Dimension)(loc, this.value.array);
        } else static if(isInstanceOf!(Matrix, Type)) {
            GlUtils.uniformMatrix!(Type.ElementType, Type.Row)(loc, this.value.array);
        } else {
            GlUtils.uniform(loc, this.value);
        }
    }

    private uint getLocation(const Program program) const {
        import sbylib.wrapper.gl.Functions;
        return GlFunction.getUniformLocation(program.id, this.name);
    }

    override string toString() {
        import std.format;
        return format!"Uniform[%s]: %s"(this.name, this.value);
    }

    inout(Type) get() inout {
        return value;
    }

    alias get this;
}
