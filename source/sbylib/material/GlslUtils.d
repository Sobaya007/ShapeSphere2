module sbylib.material.GlslUtils;

import std.string;
import std.algorithm;
import std.conv;
import std.traits;
import std.range;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Constants;

//GLSLをいいかんじにする
// 1. version宣言の省略
// 2. require文の挿入
// 3. ていうかもう頂点シェーダの省略
// 4. 必要なuniform,attributeの洗い出し
// 5. out colorの省略


/*

require normal in view as vNormal;
uniform vec4 color

*/
class GlslUtils {
static:

    AST[2] createShaders(string fragSource) {
        auto tokens = tokenize(fragSource);
        auto fragAST = new AST(tokens);
        auto vertAST = createVertexShaderAST(fragAST);
        addColorOutput(fragAST);
        addVersion(fragAST);
        return [vertAST, fragAST];
    }

    AST createVertexShaderAST(AST fragmentAst) {
        AST vertexAst = new AST;
        addVersion(vertexAst);
        auto varyings = requiredVarying(fragmentAst);
        auto requireAttributes = varyings.map!(v => declareRequiredAttribute(v.attr)).array;
        requireAttributes ~= declareRequiredAttribute(VaryingDemand.Position);
        requireAttributes = requireAttributes.sort!((a,b) => a.getCode() < b.getCode()).uniq!((a,b) => a.getCode() == b.getCode()).array;
        auto vertexDeclare = pullVertexDeclare(fragmentAst);
        foreach (attr; requireAttributes) {
            vertexAst.sentences ~= attr;
        }
        foreach (v; varyings) {
            auto tokens = tokenize(format!"out %s %s;"(cast(string)v.type, v.id));
            vertexAst.sentences ~= new VariableDeclare(tokens);
        }
        auto dependentUniforms = getDependentUniform(varyings, vertexDeclare);
        auto uniformDeclares = dependentUniforms.map!(u => declareUniform(u)).array;
        uniformDeclares = sort!((a,b) => a.getCode() < b.getCode())(uniformDeclares).uniq().array;
        vertexAst.sentences ~= uniformDeclares.map!(a => cast(Sentence)a).array;
        string[] contents;
        foreach (v; varyings) {
            contents ~= format!"%s = %s"(v.id, varyingExpression(v.attr, v.space, v.type));
        }
        contents ~= vertexExpression(vertexDeclare);
        auto tokens = tokenize(format!"void main() {\n  %s\n}"(contents.join("\n  ")));
        vertexAst.sentences ~= new FunctionDeclare(tokens);
        return vertexAst;
    }

    void addVersion(AST ast) {
        if (hasVersion(ast)) return;
        auto versionSentence = new SharpSentence();
        versionSentence.type = "version";
        versionSentence.value = "400";
        ast.sentences = versionSentence ~ ast.sentences;
    }

    void addColorOutput(AST ast) {
        if (hasColorOutput(ast)) return;
        auto tokens = tokenize("out vec4 fragColor;");
        auto colorSentence = new VariableDeclare(tokens);
        ast.sentences = colorSentence ~ ast.sentences;
    }

    SharpSentence pullVertexDeclare(AST ast) {
        auto sentences = ast.sentences.map!(s => cast(SharpSentence)s)
        .filter!(s => s !is null)
        .filter!(s => s.type == "vertex").array;
        assert(sentences.length != 0, "#vertex declare is required.");
        assert(sentences.length <= 1, "#vertex declare must be only one.");
        auto res = sentences[0];
        ast.sentences = ast.sentences.remove!(s => s == res);
        return res;
    }

    Space getVertexSpace(SharpSentence s) {
        return convert!Space(s.value);
    }

    string vertexExpression(SharpSentence s) {
        return format!"gl_Position = %s * vec4(position, 1);"(multMatrixExpression(getVertexSpace(s)));
    }

    RequireSentence[] requiredVarying(AST ast) {
        return ast.sentences.map!(s => cast(RequireSentence)s)
        .filter!(s => s !is null).array;
    }

    VariableDeclare[] requiredUniform(AST ast) {
        return ast.sentences.map!(s => cast(VariableDeclare)s)
        .filter!(s => s !is null)
        .filter!(s => s.attributes.attributes.countUntil(Attribute.Uniform) != -1).array;
    }

    BlockDeclare[] requiredUniformBlock(AST ast) {
        return ast.sentences.map!(s => cast(BlockDeclare)s)
        .filter!(s => s !is null)
        .filter!(s => s.type == StructType.Uniform).array;
    }

    UniformDemand[] getDependentUniform(RequireSentence[] requires, SharpSentence vertexDeclare) {
        return (requires.map!(r => getDependentUniform(r.space)).array.join() ~ getDependentUniform(getVertexSpace(vertexDeclare))).sort().uniq().array;
    }

    UniformDemand[] getDependentUniform(Space space) {
        final switch (space) {
        case Space.None:
            return [];
        case Space.World:
            return [UniformDemand.World];
        case Space.View:
            return [UniformDemand.World, UniformDemand.View];
        case Space.Proj:
            return [UniformDemand.World, UniformDemand.View, UniformDemand.Proj];
        }
    }

    VariableDeclare declareUniform(UniformDemand uniform) {
        Token[] tokens;
        final switch (uniform) {
        case UniformDemand.World:
            tokens = tokenize("uniform mat4 worldMatrix;");
            break;
        case UniformDemand.View:
            tokens = tokenize("uniform mat4 viewMatrix;");
            break;
        case UniformDemand.Proj:
            tokens = tokenize("uniform mat4 projMatrix;");
            break;
        }
        return new VariableDeclare(tokens);
    }

    string varyingName(VaryingDemand v) {
        final switch(v) {
        case VaryingDemand.Position:
            return "position";
        case VaryingDemand.Normal:
            return "normal";
        case VaryingDemand.UV:
            return "uv";
        }
    }

    VariableDeclare declareRequiredAttribute(VaryingDemand v) {
        Token[] tokens;
        final switch(v) {
        case VaryingDemand.Position:
            tokens = tokenize(format!"in vec3 %s;"(varyingName(v)));
            break;
        case VaryingDemand.Normal:
            tokens = tokenize(format!"in vec3 %s;"(varyingName(v)));
            break;
        case VaryingDemand.UV:
            tokens = tokenize(format!"in vec2 %s;"(varyingName(v)));
            break;
        }
        return new VariableDeclare(tokens);
    }

    string multMatrixExpression(Space s) {
        final switch (s) {
        case Space.None:
            return "";
        case Space.World:
            return "worldMatrix";
        case Space.View:
            return "viewMatrix * worldMatrix";
        case Space.Proj:
            return "projMatrix * viewMatrix * worldMatrix";
        }
    }

    string varyingExpression(VaryingDemand v, Space s, Type type) {
        string code = multMatrixExpression(s);
        final switch(v) {
        case VaryingDemand.Position:
            code ~= format!" *  vec4(%s, 1)"(varyingName(v));
            break;
        case VaryingDemand.Normal:
            code ~= format!" * vec4(%s, 0)"(varyingName(v));
            break;
        case VaryingDemand.UV:
            code ~= format!"%s"(varyingName(v));
            break;
        }
        switch (type) {
        case Type.Vec2:
            break;
        case Type.Vec3:
            code = format!"(%s).xyz"(code);
            break;
        case Type.Vec4:
            break;
        default:
            assert(false);
        }
        return format!"%s;"(code);
    }

    private bool hasVersion(AST ast) {
        return ast.sentences.any!((s) {
            if (cast(SharpSentence)s) {
                auto sharp = cast(SharpSentence)s;
                return sharp.type == "version";
            }
            return false;
        });
    }

    private bool hasColorOutput(const AST ast) {
        return ast.sentences.any!((s) {
            if (cast(VariableDeclare)s) {
                auto declare = cast(VariableDeclare)s;
                return declare.attributes.attributes.any!(a => a == Attribute.Out) && declare.type == Type.Vec4;
            }
                return false;
        });
    }
}

private {
    bool isConvertible(T)(Token[] tokens) {
        auto t = tokens[0];
        foreach (mem; [EnumMembers!T]) {
            if (mem == t.str)
                return true;
        }
        return false;
    }

    T convert(T)(string str) if (is(T == enum)) {
        foreach (mem; [EnumMembers!T]) {
            if (mem == str)
                return mem;
        }
        assert(false, format!"%s is not %s"(str, T.stringof));
    }

    T convert(T)(ref Token[] tokens) if (is(T == enum)) {
        auto t = tokens[0];
        tokens = tokens[1..$];
        return convert!T(t.str);
    }

    string convert(ref Token[] tokens) {
        auto t = tokens[0];
        tokens = tokens[1..$];
        return t.str;
    }

    void expect(ref Token[] tokens, string[] expected) {
        auto token = tokens[0];
        tokens = tokens[1..$];
        auto strs = expected.map!(a => format!"'%s'"(a)).array;
        assert(expected.any!(a => a == token.str), format!"Error[%d, %d]:%s was expected, not '%s'"(token.line, token.column, strs.join(" or "), token.str));
    }

    enum Attribute {
        In = "in",
        Out = "out",
        Uniform = "uniform",
    }
    enum StructType {
        Struct = "struct",
        Uniform = "uniform",
    }

    enum Type : string {
        Void = "void",
        Float = "float",
        Vec2 = "vec2",
        Vec3 = "vec3",
        Vec4 = "vec4",
        Mat2 = "mat2",
        Mat3 = "mat3",
        Mat4 = "mat4",
    }

    enum VaryingDemand : string {
        Position = "Position",
        Normal = "Normal",
        UV = "UV"
    }

    enum UniformDemand : string {
        World = "WorldMatrix",
        View = "ViewMatrix",
        Proj = "ProjMatrix"
    }

    enum Space : string {
        None = "",
        World = "World",
        View = "View",
        Proj = "Proj"
    }

    string indent(bool[] isEnd) {
        return isEnd.map!(e => e ? "    " : "|   ").array.join;
    }

    class Token {
        string str;
        uint line;
        uint column;

        this(){}

        this(string str, uint line, uint column) {
            this.str = str;
            this.line = line;
            this.column = column;
        }
    }

    class AttributeList {
        Attribute[] attributes;

        this() {}

        this(ref Token[] tokens) {
            while (isConvertible!Attribute(tokens)) {
                this.attributes ~= convert!Attribute(tokens);
            }
        }

        string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---AttributeList";
            foreach (i, attr; this.attributes) {
                code ~= "\n" ~ indent(isEnd) ~ "|---" ~ to!string(attr);
            }
            return code;
        }

        string getCode() {
            return attributes.map!(a => cast(string)a).join(" ");
        }
    }

    class ArgumentDeclare {
        AttributeList attributes;
        Type type;
        string id;

        this() {}

        this(ref Token[] tokens) {
            this.attributes = new AttributeList(tokens);
            this.type = convert!Type(tokens);
            this.id = convert(tokens);
        }

        string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---ArgumentDeclare\n";
            code ~= indent(isEnd) ~ "|---" ~ to!string(this.type) ~ "\n";
            code ~= this.attributes.graph(isEnd ~ true) ~ "\n";
            return code;
        }

        string getCode() {
            string code = attributes.getCode();
            if (code.length > 0) {
                code ~= " ";
            }
            code ~= format!"%s %s"(cast(string)type, id);
            return code;
        }
    }

    class ArgumentList {
        ArgumentDeclare[] arguments;

        alias arguments this;

        this() {}

        this(ref Token[] tokens) {
            while (tokens[0].str != ")") {
                this.arguments ~= new ArgumentDeclare(tokens);
                if (tokens[0].str == ",") {
                    expect(tokens, [","]);
                }
            }
            expect(tokens, [")"]);
        }

        string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---ArgumentList\n";
            foreach (i, arg; this.arguments) {
                code ~= arg.graph(isEnd ~ (i == this.arguments.length-1));
            }
            return code;
        }

        string getCode() {
            return arguments.map!(arg => arg.getCode()).join(", ");
        }
    }

    interface Sentence {
        string graph(bool[]);
        string getCode();
    }

    class VariableDeclare : Sentence {
        AttributeList attributes;
        Type type;
        string id;
        string assignedValue;

        this(ref Token[] tokens) {
            this.attributes = new AttributeList(tokens);
            this.type = convert!Type(tokens);
            this.id = convert(tokens);
            if (tokens[0].str == "=") {
                expect(tokens, ["="]);
                this.assignedValue = convert(tokens);
            }
            expect(tokens, [";"]);
        }

        override string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---Varible\n";
            code ~= indent(isEnd) ~ "|---" ~ to!string(this.type) ~ "\n";
            code ~= attributes.graph(isEnd ~ true) ~ "\n";
            return code;
        }

        override string getCode() {
            string code;
            code ~= attributes.getCode();
            if (code.length > 0) {
                code ~= " ";
            }
            code ~= format!"%s %s"(cast(string)type, id);
            if (assignedValue) {
                code ~= format!" = %s;"(assignedValue);
            } else {
                code ~= ";";
            }
            return code;
        }
    }

    class BlockDeclare : Sentence {
        StructType type;
        string id;
        VariableDeclare[] variables;

        this() {}

        this(ref Token[] tokens) {
            this.type = convert!StructType(tokens);
            this.id = convert(tokens);
            expect(tokens, ["{"]);
            while (tokens[0].str != "}") {
                this.variables ~= new VariableDeclare(tokens);
            }
            expect(tokens, ["}"]);
            expect(tokens, [";"]);
        }

        override string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---Block\n";
            code ~= indent(isEnd) ~ "|---" ~ to!string(this.type);
            foreach (i,v; this.variables) {
                code ~= "\n" ~ v.graph(isEnd ~ (i == this.variables.length-1));
            }
            return code;
        }

        override string getCode() {
            string code = format!"%s %s {\n"(cast(string)type, id);
            foreach (v; variables) {
                code ~= format!"  %s\n"(v.getCode());
            }
            code ~= "};";
            return code;
        }
    }

    class FunctionDeclare : Sentence {
        Type returnType;
        string id;
        ArgumentList arguments;
        string content;

        this() {}

        this(ref Token[] tokens) {
            this.returnType = convert!Type(tokens);
            this.id = convert(tokens);
            expect(tokens, ["("]);
            this.arguments = new ArgumentList(tokens);
            expect(tokens, ["{"]);
            this.content = convert(tokens);
            expect(tokens, ["}"]);
        }

        override string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---Function\n";
            code ~= indent(isEnd) ~ "|---" ~ to!string(this.returnType) ~ "\n";
            code ~= this.arguments.graph(isEnd ~ true);
            return code;
        }

        override string getCode() {
            return format!"%s %s(%s) {%s}"(cast(string)returnType, id, arguments.getCode(), content);
        }
    }

    class SharpSentence : Sentence {
        string type;
        string value;

        this() {}

        this(ref Token[] tokens) {
            assert(tokens[0].str == "#");
            this.type = tokens[1].str;
            this.value = tokens[2].str;
            tokens = tokens[3..$];
        }

        override string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---Sharp\n";
            code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
            code ~= indent(isEnd) ~ "|---" ~ this.value ~ "\n";
            return code;
        }

        override string getCode() {
            return format!"#%s %s"(this.type, this.value);
        }
    }

    class RequireSentence : Sentence {
        VaryingDemand attr;
        Space space;
        Type type;
        string id;

        this(ref Token[] tokens) {
            expect(tokens, ["require"]);
            this.attr = convert!VaryingDemand(tokens);
            if (tokens[0].str == "in") {
                expect(tokens, ["in"]);
                this.space = convert!Space(tokens);
            }
            expect(tokens, ["as"]);
            this.type = convert!Type(tokens);
            this.id = convert(tokens);
            expect(tokens, [";"]);
        }

        override string graph(bool[] isEnd) {
            string code = indent(isEnd[0..$-1]) ~ "|---Require\n";
            code ~= indent(isEnd) ~ "|---" ~ this.attr ~ "\n";
            code ~= indent(isEnd) ~ "|---" ~ this.space ~ "\n";
            code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
            return code;
        }

        override string getCode() {
            return format!"in %s %s;"(cast(string)this.type, this.id);
        }
    }

    class AST {
        Sentence[] sentences;

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
                    sentences ~= new SharpSentence(tokens);
                } else if (tokens[0].str == "require") {
                    sentences ~= new RequireSentence(tokens);
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
    }

    enum Delimitor = [' ', '\t', '\n', '\r'];
    enum Symbol = [';', '{', '}', '(', ')', ',', '#'];

    Token[] tokenize(string code) {
        import std.stdio;
        Token[] res;
        Token buffer = new Token;
        bool isFunction = false;
        int parensCount = 0;
        uint line = 1, column = 0;
        foreach (c; code) {
            if (isFunction) {
                column++;
                if (c == '{') {
                    parensCount++;
                } else if (c == '}') {
                    parensCount--;
                    if (parensCount == 0) {
                        res ~= buffer;
                        buffer = new Token;
                        res ~= new Token("}", line, column);
                        isFunction = false;
                    }
                } else {
                    buffer.str ~= c;
                    if (c == '\n') {
                        column = 0;
                        line++;
                    }
                }
            } else {
                column++;
                if (Delimitor.any!(d => d == c)) {
                    if (buffer.str.length > 0) {
                        res ~= buffer;
                        buffer = new Token;
                    }
                    if (c == '\n') {
                        column = 0;
                        line++;
                    }
                } else if (Symbol.any!(s => s == c)) {
                    if (buffer.str.length > 0) {
                        res ~= buffer;
                        buffer = new Token;
                    }
                    res ~= new Token(to!string(c), line, column);
                    if (res.length >= 2 && res[$-2].str == ")" && res[$-1].str == "{") {
                        isFunction = true;
                        parensCount = 1;
                    }
                } else {
                    if (buffer.line == 0) {
                        buffer.line = line;
                        buffer.column = column;
                    }
                    buffer.str ~= c;
                }
            }
        }
        return res;
    }
}

unittest {
    import std.stdio, std.file;
    auto file = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto asts = GlslUtils.createShaders(file);
    writeln(asts[0].getCode());
    writeln(asts[1].getCode());
}
