module sbylib.material.glsl.Ast;

import sbylib.material.glsl.Argument;
import sbylib.material.glsl.Comment;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.FunctionDeclare;
import sbylib.material.glsl.LayoutDeclare;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.AttributeDemand;
import sbylib.material.glsl.Sharp;
import sbylib.material.glsl.PrecisionDeclare;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.RequireUniform;
import sbylib.material.glsl.RequireShader;

import std.traits;
import std.algorithm;
import std.range;
import std.conv;

class Ast {
    string name;
    Statement[] statements;

    this() {}

    this(string str) {
        Token[] tokens = tokenize(str);
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
            } else if (tokens[0].str == "precision") {
                statements ~= new PrecisionDeclare(tokens);
            } else if (tokens[0].str == "layout") {
                auto tok = tokens.find!(t => t.str == ")");
                if (tok[2].str == ";") {
                    // if this token is variable declare's part, thre is more than 1 tokens between ')' and ';'
                    statements ~= new LayoutDeclare(tokens);
                } else {
                    statements ~= new VariableDeclare(tokens);
                }
            } else if (tokens[0].str == "#") {
                statements ~= new Sharp(tokens);
            } else if (tokens[0].str == "require") {
                if (isConvertible!(AttributeDemand, getAttributeDemandKeyWord)(tokens[1].str)) {
                    statements ~= new RequireAttribute(tokens);
                } else if (isConvertible!(UniformDemand, getUniformDemandName)(tokens[1].str)) {
                    statements ~= new RequireUniform(tokens);
                } else if (tokens[1].str == "Shader") {
                    statements ~= new RequireShader(tokens);
                } else {
                    assert(false, to!string(tokens));
                }
            } else if (tokens[0].str == "//") {
                statements ~= new Comment(tokens);
            } else {
                //Variable or Function
                assert(tokens.length >= 3);
                if (tokens[2].str == "(") {
                    //Function
                    statements ~= new FunctionDeclare(tokens);
                } else if (tokens[2].str == "=" || tokens[2].str == ";") {
                    statements ~= new VariableDeclare(tokens);
                } else {
                    assert(false, to!string(tokens));
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
        auto functions = this.getStatements!(FunctionDeclare);
        auto mainFunction  = functions.filter!(f => f.id == "main").map!(f => cast(Statement)f).array;
        auto otherFunction = functions.filter!(f => f.id != "main").map!(f => cast(Statement)f).array;
        auto sharps = this.getStatements!(Sharp).map!(f => cast(Statement)f).array;
        auto layouts = this.getStatements!(LayoutDeclare).map!(f => cast(Statement)f).array;
        auto others    = statements.filter!(s =>
            cast(FunctionDeclare)s is null
            && cast(Sharp)s is null
            && cast(LayoutDeclare)s is null
        ).array;
        return (sharps ~ layouts ~ others ~ otherFunction ~ mainFunction).map!(s => s.getCode()).join("\n");
    }

    T[] getStatements(T)() const {
        return this.statements.map!(sentence => cast(T)sentence).filter!(sentence => sentence !is null).array;
    }

    void addRequiredVertexInVariableDeclares(Ast ast) {
        this.addUniqueStatements(ast.getRequiredAttributes(true).map!(r => r.getVertexIn()).array);
    }

    void addRequiredGeometryInVariableDeclares(Ast ast) {
        this.addUniqueStatements(ast.getRequiredAttributes(true)
                .filter!(r => r.variable.id != "g_position")
                .map!(r => r.getGeometryIn()).array);
    }

    void addRequiredOutVariableDeclares(Ast ast) {
        // if 'position' requirement is only made by '#vertex' declare,
        // there is no need to add 'out vec4 position' declare.
        import std.format;
        this.addUniqueStatements(
            ast.getRequiredAttributes(false).map!(r => r.getVertexOut()).array
        );
    }

    void addRequiredUniformVaribleDeclares(Ast ast) {
        this.addUniqueStatements(ast.getRequiredUniformDemandDeclares);
    }

    void addVertexMainFunction(Ast ast) {
        this.addMainFunction(ast.getRequiredAttributes(true).map!(r => r.getVertexBodyCode()).array);
    }


    import sbylib.material.glsl.Space;

    void addEmitVertexDeclare(Ast ast) {
        import std.meta;

        auto to = ast.getVertexDeclare().getRequireAttribute().space;
        static foreach (space; AliasSeq!(Space.Local, Space.World, Space.View, Space.Proj)) {
            if (space.getUniformDemands.length <= to.getUniformDemands.length) {
                addEmitVertexDeclare(ast, space, to);
            }
        }
        addEmitVertexCommonDeclare(ast);
    }

    void addEmitVertexDeclare(Ast ast, Space from, Space to) {
        import std.format;
        auto uniforms = getUniformDemands(from, to).map!(a => getUniformDemandName(a)).array;
        string[] exprs = uniforms ~ "vertex";
        this.statements = FunctionDeclare.generateFunction("emit"~from.to!string~"Vertex", "void", ["int i", "vec4 vertex"],
            [format!"gl_Position = %s;"(exprs.join(" * "))]
            ~ "emitVertexCommon(i);"
            ) ~ this.statements;
    }

    void addEmitVertexCommonDeclare(Ast ast) {
        import std.format;
        this.statements = FunctionDeclare.generateFunction("emitVertexCommon", "void", ["int i"],
            ast.getRequiredAttributes(false).map!(r => r.getGeometryBodyCode()).array
            ~ "EmitVertex();") ~ this.statements;
    }

    void addUniqueStatements(Statement[] statements) {
        this.statements ~= 
            statements
            .sort!((a,b) => a.getCode() < b.getCode())
            .uniq!((a,b) => a.getCode() == b.getCode())
            .array;
    }

    RequireAttribute[] getRequiredAttributes(bool containPositionRequire) {
        auto requires = this.getStatements!RequireAttribute();
        if (containPositionRequire) {
            requires ~= this.getVertexDeclare().getRequireAttribute();
        }
        return requires;
    }

    Statement[] getRequiredUniformDemandDeclares() {
        import sbylib.material.glsl.Space;
        return getRequiredAttributes(true)
            .map!(r => r.space.getUniformDemands())
            .join()
            .map!(u => getUniformDemandDeclare(u))
            .join();
    }

    void replaceID(string delegate(string) replace) {
        import std.conv;
        import std.stdio;
        string[] IDs = [
            this.getStatements!RequireAttribute.map!(a => a.variable.id).array,
            this.getStatements!VariableDeclare.map!(v => v.id).array,
            this.getStatements!BlockDeclare.map!(b => b.getIDs()).join(),
            this.getStatements!FunctionDeclare.map!(f => f.getIDs()).join()].join()
        .filter!(id => id.length > 0).array;
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

    FunctionDeclare getMainFunction() {
        auto result = this.getStatements!FunctionDeclare.filter!(func => func.id == "main").array;

        assert(result.length != 0, "main function is required.");
        assert(result.length <= 1, "main function must be only one.");
        return result[0];
    }

    void addMainFunction(string[] contents) {
        this.statements ~= FunctionDeclare.generateFunction("main", "void", [], contents);
    }

    void completeColorOutput() {
        if (hasColorOutput()) return;
        this.statements = new VariableDeclare("out vec4 fragColor;") ~ this.statements;
    }

    private bool hasColorOutput() {
        return this.getStatements!VariableDeclare()
        .any!(declare => declare.attributes.has(Attribute.Out) && declare.type == "vec4");
    }

    Sharp getVertexDeclare() {
        auto statements = this.getStatements!Sharp().filter!(sharp => sharp.type == "vertex").array;
        assert(statements.length != 0, "#vertex declare is required.");
        assert(statements.length <= 1, "#vertex declare must be only one.");
        return statements[0];
    }

    void completeVersionDeclare() {
        if (hasVersionDeclare()) return;
        this.statements = Sharp.generateVersionDeclare() ~ this.statements;
    }
    
    private bool hasVersionDeclare() {
        return this.getStatements!Sharp()
        .any!(sharp => sharp.type == "version");
    }

    void addIdOutput() {
        this.statements ~= new VariableDeclare("uniform int _id;");
        this.statements ~= new VariableDeclare("layout(location=1) out vec4 idBuffer;");
        this.getMainFunction().insertIdOutput("_id", "idBuffer");
    }

    void completeComputeLayoutDeclare(int localX, int localY) {
        import std.format;
        this.statements ~= new LayoutDeclare(format!"layout(local_size_x=%d, local_size_y=%d) in;"(localX, localY));
    }
}
