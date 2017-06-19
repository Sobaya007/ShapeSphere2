module sbylib.material.glsl.GlslUtils;

import std.string;
import std.algorithm;
import std.conv;
import std.traits;
import std.range;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Constants;
import sbylib.light.PointLight;

import sbylib.material.glsl.Ast;
import sbylib.material.glsl.BlockType;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Sharp;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.BlockDeclare;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.FunctionDeclare;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.glsl.Space;
import sbylib.material.glsl.AttributeDemand;

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

        //Pull fragment #vertex
        Sharp vertexDeclare = pullVertexDeclare(fragmentAst);

        RequireAttribute[] requires = fragmentAst.getSentence!RequireAttribute();
        RequireAttribute positionRequireAttribute = vertexDeclare.getRequireAttribute();

        //Add Version
        addVersion(vertexAst);

        //Add vertex in declare
        auto vertexIn = (requires ~ positionRequireAttribute).map!(v => v.getVertexIn()).array;
        vertexIn = vertexIn
        .sort!((a,b) => a.getCode() <  b.getCode())
        .uniq!((a,b) => a.getCode() == b.getCode())
        .array;
        vertexAst.sentences ~= vertexIn;

        //Add vertex out declare
        vertexAst.sentences ~= requires.map!(r => r.getVertexOut()).array;

        //Add vertex uniform declare
        auto dependentUniforms = (requires ~ positionRequireAttribute).map!(r => r.space.getUniformDemands()).join().sort().uniq().array;
        auto uniformDeclares = dependentUniforms.map!(u => getUniformDemandDeclare(u)).join();
        vertexAst.sentences ~= uniformDeclares;

        //Add main function
        string[] contents;
        contents ~= requires.map!(r => r.getVertexBodyCode()).array;
        contents ~= vertexDeclare.getGlPositionCode();
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

    string vertexExpression(Sharp s) {
        return format!"gl_Position = %s * vec4(position, 1);"(s.getVertexSpace().getUniformDemands().map!(u => u.getUniformDemandName()).join(" * "));
    }

    VariableDeclare[] requiredUniform(Ast ast) {
        return ast.getSentence!VariableDeclare()
        .filter!(declare => declare.attributes.has(Attribute.Uniform)).array;
    }

    BlockDeclare[] requiredUniformBlock(Ast ast) {
        return ast.getSentence!BlockDeclare()
        .filter!(s => s.type == BlockType.Uniform).array;
    }

    UniformDemand[] getDependentUniform(RequireAttribute[] requires, Sharp vertexDeclare) {
        return (requires.map!(r => getDependentUniform(r.space)).array.join() ~ getDependentUniform(vertexDeclare.getVertexSpace())).sort().uniq().array;
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

    private bool hasVersion(Ast ast) {
        return ast.getSentence!Sharp()
        .any!(sharp => sharp.type == "version");
    }

    private bool hasColorOutput(const Ast ast) {
        return ast.getSentence!VariableDeclare()
        .any!(declare => declare.attributes.has(Attribute.Out) && declare.type == "vec4");
    }
}

unittest {
    import std.stdio, std.file;
    auto file = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto asts = GlslUtils.createShaders(file);
    writeln(asts[1].getCode());
    writeln(GlslUtils.getUniformNames(asts));
}