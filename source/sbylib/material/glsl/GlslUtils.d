module sbylib.material.glsl.GlslUtils;

import std.string;
import std.algorithm;
import std.conv;
import std.traits;
import std.range;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Constants;

import sbylib.material.glsl.Ast;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Sharp;
import sbylib.material.glsl.Require;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.FunctionDeclare;
import sbylib.material.glsl.Function;

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

    Ast[2] createShaders(string fragSource) {
        auto tokens = tokenize(fragSource);
        auto fragAst = new Ast(tokens);
        auto vertAst = createVertexShaderAst(fragAst);
        addColorOutput(fragAst);
        addVersion(fragAst);
        return [vertAst, fragAst];
    }

    string[] getUniformNames(Ast[] asts) {
        return asts.map!(ast => ast.getSentence!VariableDeclare()
                .filter!(a => a.attributes.has(Attribute.Uniform))
                .map!(a => a.id).array).join().sort().uniq().array;
    }

    Ast createVertexShaderAst(Ast fragmentAst) {
        Ast vertexAst = new Ast;
        addVersion(vertexAst);
        auto varyings = fragmentAst.getSentence!Require();
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
        vertexAst.sentences ~= uniformDeclares.map!(a => cast(Statement)a).array;
        string[] contents;
        foreach (v; varyings) {
            contents ~= format!"%s = %s"(v.id, varyingExpression(v.attr, v.space, v.type));
        }
        contents ~= vertexExpression(vertexDeclare);
        auto tokens = tokenize(format!"void main() {\n  %s\n}"(contents.join("\n  ")));
        vertexAst.sentences ~= new FunctionDeclare(tokens);
        return vertexAst;
    }

    void addVersion(Ast ast) {
        if (hasVersion(ast)) return;
        auto versionStatement = new Sharp();
        versionStatement.type = "version";
        versionStatement.value = "400";
        ast.sentences = versionStatement ~ ast.sentences;
    }

    void addColorOutput(Ast ast) {
        if (hasColorOutput(ast)) return;
        auto tokens = tokenize("out vec4 fragColor;");
        auto colorStatement = new VariableDeclare(tokens);
        ast.sentences = colorStatement ~ ast.sentences;
    }

    Sharp pullVertexDeclare(Ast ast) {
        auto sentences = ast.getSentence!Sharp().filter!(sharp => sharp.type == "vertex").array;
        assert(sentences.length != 0, "#vertex declare is required.");
        assert(sentences.length <= 1, "#vertex declare must be only one.");
        auto res = sentences[0];
        ast.sentences = ast.sentences.remove!(s => s == res);
        return res;
    }

    Space getVertexSpace(Sharp s) {
        return convert!Space(s.value);
    }

    string vertexExpression(Sharp s) {
        return format!"gl_Position = %s * vec4(position, 1);"(multMatrixExpression(getVertexSpace(s)));
    }

    VariableDeclare[] requiredUniform(Ast ast) {
        return ast.getSentence!VariableDeclare()
        .filter!(declare => declare.attributes.has(Attribute.Uniform)).array;
    }

    BlockDeclare[] requiredUniformBlock(Ast ast) {
        return ast.getSentence!BlockDeclare()
        .filter!(s => s.type == StructType.Uniform).array;
    }

    UniformDemand[] getDependentUniform(Require[] requires, Sharp vertexDeclare) {
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

    private bool hasVersion(Ast ast) {
        return ast.getSentence!Sharp()
        .any!(sharp => sharp.type == "version");
    }

    private bool hasColorOutput(const Ast ast) {
        return ast.getSentence!VariableDeclare()
        .any!(declare => declare.attributes.has(Attribute.Out) && declare.type == Type.Vec4);
    }
}

unittest {
    import std.stdio, std.file;
    auto file = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto asts = GlslUtils.createShaders(file);
    writeln(GlslUtils.getUniformNames(asts));
}
