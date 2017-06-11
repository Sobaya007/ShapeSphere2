module sbylib.gl.Uniform;

import derelict.opengl;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import std.traits;
import std.conv;

interface Uniform {
    void apply(uint) inout;
    string getName() inout;
    void assign(S)(S val);
}

class UniformTemp(Type) : Uniform {
    immutable {
        string name;
    }
    Type value;

    this(string name) {
        this.name = name;
    }

    string getString() {
        return Type.stringof ~ " " ~ name ~ ";";
    }

    override string getName() inout {
        return this.name;
    }

    override void apply(uint loc) inout {
        static if (isInstanceOf!(Vector, Type)) {
            mixin("glUniform" ~ to!string(Type.dimension) ~ Type.type[0] ~ "v(loc, 1, this.value.elements.ptr);");
        } else static if(isInstanceOf!(Matrix, Type)) {
            static assert(Type.dimension1 == Type.dimension2);
            mixin("glUniformMatrix" ~ to!string(Type.dimension1) ~ Type.type[0] ~ "v(loc, 1,GL_TRUE, this.value.array.ptr);");
        } else {
            mixin("glUniform1" ~ Type.stringof[0] ~ "(loc, this.value);");
        }
    }

    alias value this;
}

alias ufloat = UniformTemp!(float);
alias uvec2 = UniformTemp!(vec2);
alias uvec3 = UniformTemp!(vec3);
alias uvec4 = UniformTemp!(vec4);
alias umat4 = UniformTemp!(mat4);
