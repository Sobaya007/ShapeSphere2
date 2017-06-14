module sbylib.material.GlslUtils;

import std.string;
import std.algorithm;
import std.conv;
import std.traits;
import std.range;


//GLSLをいいかんじにする
// 1. version宣言の省略
// 2. require文の挿入
// 3. ていうかもう頂点シェーダの省略
// 4. 必要なuniform,attributeの洗い出し
// 5. out colorの省略


/*

require normal in space as vNormal;
uniform vec4 color

*/
class GlslUtils {
static:
    string deal(string fsCode) {
        return [getVersion(fsCode)].join("\n");
    }

    string getVersion(string fsCode) {
        if (fsCode.startsWith("#version")) return "";
        return "#version 400\n";
    }
}

bool isConvertible(T)(string s) {
    foreach (mem; [EnumMembers!T]) {
        if (mem == s)
            return true;
    }
    return false;
}

T convert(T)(string s) {
    foreach (mem; [EnumMembers!T]) {
        if (mem == s)
            return mem;
    }
    assert(false, format!"%s is not a member of %s"(s, T.stringof));
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

enum Type {
    Void = "void",
    Float = "float",
    Vec2 = "vec2",
    Vec3 = "vec3",
    Vec4 = "vec4",
    Mat2 = "mat2",
    Mat3 = "mat3",
    Mat4 = "mat4",
}

string indent(bool[] isEnd) {
    return isEnd.map!(e => e ? "    " : "|   ").array.join;
}

class AttributeList {
    Attribute[] attributes;

    this(ref string[] tokens) {
        while (isConvertible!Attribute(tokens[0])) {
            this.attributes ~= convert!Attribute(tokens[0]);
            tokens = tokens[1..$];
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

    this(ref string[] tokens) {
        this.attributes = new AttributeList(tokens);
        this.type = convert!Type(tokens[0]);
        this.id = tokens[1];
        tokens = tokens[2..$];
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

    this(ref string[] tokens) {
        while (tokens[0] != ")") {
            this.arguments ~= new ArgumentDeclare(tokens);
            if (tokens[0] == ",") {
                tokens = tokens[1..$];
            }
        }
        assert(tokens[0] == ")");
        tokens = tokens[1..$];
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

    this(ref string[] tokens) {
        this.attributes = new AttributeList(tokens);
        this.type = tokens[0].convert!Type;
        this.id = tokens[1];
        tokens = tokens[2..$];
        if (tokens[0] == "=") {
            this.assignedValue = tokens[1];
            tokens = tokens[2..$];
        }
        assert(tokens[0] == ";");
        tokens = tokens[1..$];
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

    this(ref string[] tokens) {
        this.type = convert!StructType(tokens[0]);
        this.id = tokens[1];
        assert(tokens[2] == "{");
        tokens = tokens[3..$]; 
        while (tokens[0] != "}") {
            this.variables ~= new VariableDeclare(tokens);
        }
        assert(tokens[0] == "}");
        tokens = tokens[1..$];
        if (tokens[0] == ";") {
            tokens = tokens[1..$];
        }
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
        code ~= "}";
        return code;
    }
}

class FunctionDeclare : Sentence {
    Type returnType;
    string id;
    ArgumentList arguments;
    string content;

    this(ref string[] tokens) {
        this.returnType = tokens[0].convert!Type;
        this.id = tokens[1];
        assert(tokens[2] == "(");
        tokens = tokens[3..$];
        this.arguments = new ArgumentList(tokens);
        assert(tokens[0] == "{");
        this.content = tokens[1];
        assert(tokens[2] == "}");
        tokens = tokens[3..$];
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

class AST {
    Sentence[] sentences;

    this(string[] tokens) {
        while (tokens.length > 0) {
            if (isConvertible!Type(tokens[0])) {
                //Variable or Function
                if (tokens[2] == "(") {
                    //Function
                    sentences ~= new FunctionDeclare(tokens);
                } else if (tokens[2] == "=" || tokens[2] == ";") {
                    sentences ~= new VariableDeclare(tokens);
                }
            } else if (isConvertible!Attribute(tokens[0])) {
                //Variable or Block(uniform)
                if (tokens[2] == "{") {
                    //Block(uniform)
                    sentences ~= new BlockDeclare(tokens);
                } else {
                    //Variable
                    sentences ~= new VariableDeclare(tokens);
                }
            } else if (tokens[0] == "struct") {
                sentences ~= new BlockDeclare(tokens);
            } else {
                assert(false, tokens.to!string());
            }
        }
    }

    override string toString() {
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
enum Symbol = [';', '{', '}', '(', ')', ','];

string[] tokenize(string code) {
    import std.stdio;
    string[] res;
    string buffer;
    bool isFunction = false;
    int parensCount = 0;
    foreach (c; code) {
        if (isFunction) {
            if (c == '{') {
                parensCount++;
            } else if (c == '}') {
                parensCount--;
                if (parensCount == 0) {
                    res ~= buffer;
                    buffer = "";
                    res ~= "}";
                    isFunction = false;
                }
            } else {
                buffer ~= c;
            }
        } else {
            if (Delimitor.any!(d => d == c)) {
                if (buffer.length > 0) {
                    res ~= buffer;
                    buffer = "";
                }
            } else if (Symbol.any!(s => s == c)) {
                if (buffer.length > 0) {
                    res ~= buffer;
                    buffer = "";
                }
                res ~= to!string(c);
                if (res[$-2] == ")" && res[$-1] == "{") {
                    isFunction = true;
                    parensCount = 1;
                }
            } else {
                buffer ~= c;
            }
        }
    }
    return res;
}

unittest {
 import std.stdio, std.file;
    auto file = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto tokens = tokenize(file);
    auto ast = new AST(tokens);
    writeln(ast.getCode());
}
