module sbylib.wrapper.gl.Uniform;
import derelict.opengl;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Program;
import std.traits;
import std.conv;
import std.string;
import std.format;

alias ubool = UniformTemp!(bool);
alias ufloat = UniformTemp!(float);
alias uvec2 = UniformTemp!(vec2);
alias uvec3 = UniformTemp!(vec3);
alias uvec4 = UniformTemp!(vec4);
alias umat4 = UniformTemp!(mat4);

interface Uniform {
    string getName() const;
    void setName(string);
    void apply(const Program, ref uint, ref uint) const;
}

class UniformTemp(Type) : Uniform {
    string name;
    Type value;

    this(string name) {
        this.name = name;
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const out {
        checkGlError();
    } body {
        auto loc = this.getLocation(program);
        static if (isInstanceOf!(Vector, Type)) {
            mixin(format!"glUniform%d%sv(loc, 1, this.value.array.ptr);"(Type.dimension, Type.type[0]));
        } else static if(isInstanceOf!(Matrix, Type)) {
            static assert(Type.dimension1 == Type.dimension2);
            mixin(format!"glUniformMatrix%d%sv(loc, 1, GL_TRUE, this.value.array.ptr);"(Type.dimension1, Type.type[0]));
        } else static if (is(Type == bool)) {
            glUniform1i(loc, this.value);
        } else {
            mixin(format!"glUniform1%s(loc, this.value);"(Type.stringof[0]));
        }
    }

    private uint getLocation(const Program program) const out {
        checkGlError();
    } body {
        int uLoc = glGetUniformLocation(program.id, this.name.toStringz);
        //if (uLoc == -1) writeln(name ~ " is not found or used."); 
        return uLoc;
    }

    override string toString() const {
        import std.format;
        return format!"Uniform[%s]: %s"(this.name, this.value);
    }

    inout(Type) get() inout {
        return value;
    }

    alias value this;
}
