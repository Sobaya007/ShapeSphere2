module sbylib.wrapper.gl.Uniform;
import derelict.opengl;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Texture;
import std.traits;
import std.conv;
import std.string;
import std.format;

alias ubool = TypedUniform!(bool);
alias ufloat = TypedUniform!(float);
alias uvec2 = TypedUniform!(vec2);
alias uvec3 = TypedUniform!(vec3);
alias uvec4 = TypedUniform!(vec4);
alias umat4 = TypedUniform!(mat4);
alias utexture = TypedUniform!(Texture);

interface Uniform {
    string getName() const;
    void setName(string);
    void apply(const Program, ref uint, ref uint) const;
}

auto createUniform(T)(T val, string name) if (isAcceptable!(T)) {
    return new TypedUniform!(T)(name, val);
}

private template isAcceptable(T) {
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
    string name;
    Type value;

    this(string name) {
        this.name = name;
    }

    this(string name, Type value) {
        this.name = name;
        this = value;
    }

    void opAssign(Type value) {
        this.value = value;
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const out {
        GlFunction.checkError();
    } body {
        auto loc = this.getLocation(program);
        static if (is(Type == Texture)) {
            assert(this.value !is null, "UniformTexture's value is null");
            Texture.activate(textureUnit);
            this.value.bind();
            glUniform1i(loc, textureUnit);
            textureUnit++;
        } else static if (isInstanceOf!(Vector, Type)) {
            mixin(format!"glUniform%d%sv(loc, 1, this.value.array.ptr);"(Type.Dimension, Type.ElementType.stringof[0]));
        } else static if(isInstanceOf!(Matrix, Type)) {
            mixin(format!"glUniformMatrix%d%sv(loc, 1, GL_TRUE, this.value.array.ptr);"(Type.Row, Type.ElementType.stringof[0]));
        } else static if (is(Type == bool)) {
            glUniform1i(loc, this.value);
        } else {
            mixin(format!"glUniform1%s(loc, this.value);"(Type.stringof[0]));
        }
    }

    private uint getLocation(const Program program) const out {
        GlFunction.checkError();
    } body {
        int uLoc = glGetUniformLocation(program.id, this.name.toStringz);
        //assert(uLoc != -1, name ~ " is not found or used."); 
        return uLoc;
    }

    override string toString() {
        import std.format;
        return format!"Uniform[%s]: %s"(this.name, this.value);
    }

    inout(Type) get() inout {
        return value;
    }

    alias value this;
}
