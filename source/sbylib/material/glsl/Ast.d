module sbylib.material.glsl.Ast;

import sbylib.material.glsl.Token;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.FunctionDeclare;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.Sharp;
import sbylib.material.glsl.Require;

import std.traits;
import std.algorithm;
import std.range;

class Ast {
    Statement[] sentences;

    this() {}

    this(Token[] tokens) {
        while (tokens.length > 0) {
            if (isConvertible!Type(tokens)) {
                //Variable or Function
                if (tokens[2].str == "(") {
                    //Function
                    sentences ~= new FunctionDeclare(tokens);
                } else if (tokens[2].str == "=" || tokens[2].str == ";") {
                    sentences ~= new VariableDeclare(tokens);
                }
            } else if (isConvertible!Attribute(tokens)) {
                //Variable or Block(uniform)
                if (tokens[2].str == "{") {
                    //Block(uniform)
                    sentences ~= new BlockDeclare(tokens);
                } else {
                    //Variable
                    sentences ~= new VariableDeclare(tokens);
                }
            } else if (tokens[0].str == "struct") {
                sentences ~= new BlockDeclare(tokens);
            } else if (tokens[0].str == "#") {
                sentences ~= new Sharp(tokens);
            } else if (tokens[0].str == "require") {
                sentences ~= new Require(tokens);
            } else {
                auto expected = ["struct", "#", "require"];
                foreach (type; EnumMembers!Type) {
                    expected ~= cast(string)type;
                }
                foreach (attr; EnumMembers!Attribute) {
                    expected ~= cast(string)attr;
                }
                expect(tokens, expected);
            }
        }
    }

    override string toString() {
        import std.stdio;
        string code = "ROOT\n";
        foreach (i, s; this.sentences) {
            code ~= s.graph([i == this.sentences.length-1]);
        }
        return code;
    }

    string getCode() {
        return sentences.map!(s => s.getCode()).join("\n");
    }

    T[] getSentence(T)() const {
        return this.sentences.map!(sentence => cast(T)sentence).filter!(sentence => sentence !is null).array;
    }
}
