module sbylib.material.glsl.Ast;

import sbylib.material.glsl.Token;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.FunctionDeclare;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.AttributeDemand;
import sbylib.material.glsl.Sharp;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.RequireUniform;

import std.traits;
import std.algorithm;
import std.range;

class Ast {
    Statement[] statements;

    this() {}

    this(Token[] tokens) {
        while (tokens.length > 0) {
            if (isConvertible!(Attribute, getAttributeCode)(tokens)) {
                //Variable or Block(uniform)
                if (tokens[2].str == "{") {
                    //Block(uniform)
                    statements ~= new BlockDeclare(tokens);
                } else {
                    //Variable
                    statements ~= new VariableDeclare(tokens);
                }
            } else if (tokens[0].str == "struct") {
                statements ~= new BlockDeclare(tokens);
            } else if (tokens[0].str == "#") {
                statements ~= new Sharp(tokens);
            } else if (tokens[0].str == "require") {
                if (isConvertible!(AttributeDemand, getAttributeDemandKeyWord)(tokens[1].str)) {
                    statements ~= new RequireAttribute(tokens);
                } else if (isConvertible!(UniformDemand, getUniformDemandName)(tokens[1].str)) {
                    statements ~= new RequireUniform(tokens);
                } else {
                    assert(false);
                }
            } else {
                //Variable or Function
                if (tokens[2].str == "(") {
                    //Function
                    statements ~= new FunctionDeclare(tokens);
                } else if (tokens[2].str == "=" || tokens[2].str == ";") {
                    statements ~= new VariableDeclare(tokens);
                } else {
                    assert(false);
                }
            }
        }
    }

    override string toString() {
        string code = "ROOT\n";
        foreach (i, s; this.statements) {
            code ~= s.graph([i == this.statements.length-1]);
        }
        return code;
    }

    string getCode() {
        return statements.map!(s => s.getCode()).join("\n");
    }

    T[] getStatements(T)() const {
        return this.statements.map!(sentence => cast(T)sentence).filter!(sentence => sentence !is null).array;
    }

    bool hasVersion() {
        return this.getStatements!Sharp()
        .any!(sharp => sharp.type == "version");
    }

    bool hasColorOutput() {
        return this.getStatements!VariableDeclare()
        .any!(declare => declare.attributes.has(Attribute.Out) && declare.type == "vec4");
    }
}
