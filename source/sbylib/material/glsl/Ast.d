module sbylib.material.glsl.Ast;

import sbylib.material.glsl.Argument;
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
    string name;
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

    void replaceID(string delegate(string) replace) {
        import std.conv;
        string[] IDs = [
            this.getStatements!VariableDeclare.map!(v => v.id).array,
            this.getStatements!BlockDeclare.map!(b => b.getIDs()).join(),
            this.getStatements!FunctionDeclare.map!(f => f.getIDs()).join()].join();
        foreach (statement; this.statements.map!(to!Object)) {
            statement.castSwitch!(
                    (VariableDeclare v) => v.replaceID(replace),
                    (BlockDeclare b) => b.replaceID(replace),
                    (FunctionDeclare f) => f.replaceID(replace, IDs),
                    (RequireAttribute a) => a.replaceID(replace),
                    (Object obj) {});
        }
    }

    void outParameterIntoMain() {
        auto outParameters = this.getStatements!VariableDeclare.filter!(v => v.attributes.has(Attribute.Out)).array;
        this.statements = this.statements.remove!(
                s => cast(VariableDeclare)s && (cast(VariableDeclare)s).attributes.has(Attribute.Out));
        auto mainFunction = this.getMainFunction();
        mainFunction.arguments.arguments ~= outParameters.map!(v => new Argument(v.getCode())).array;
    }

    Sharp getVertexDeclare() {
        auto statements = this.getStatements!Sharp().filter!(sharp => sharp.type == "vertex").array;
        assert(statements.length != 0, "#vertex declare is required.");
        assert(statements.length <= 1, "#vertex declare must be only one.");
        return statements[0];
    }

    FunctionDeclare getMainFunction() {
        auto result = this.getStatements!FunctionDeclare.filter!(func => func.id == "main").array;

        assert(result.length != 0, "main function is required.");
        assert(result.length <= 1, "main function must be only one.");
        return result[0];
    }
}
