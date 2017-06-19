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
import sbylib.material.glsl.Require;
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
        addVersion(vertexAst);
        auto requires = fragmentAst.getSentence!Require();
        requires ~= new Require("require Position in Proj as vec3 position;");
        auto vertexIn = requires.map!(v => v.getVertexIn()).array;
        vertexIn = vertexIn.sort!((a,b) => a.getCode() < b.getCode())().uniq().array;
        vertexAst.sentences ~= vertexIn;
        vertexAst.sentences ~= requires.map!(r => new VariableDeclare(r.getCode().replace("in", "out"))).array;
        pullVertexDeclare(fragmentAst);
        auto dependentUniforms = requires.map!(r => r.space.getUniformDemands()).join().sort().uniq().array;
        auto uniformDeclares = dependentUniforms.map!(u => declareUniform(u)).join();
        uniformDeclares = sort!((a,b) => a.getCode() < b.getCode())(uniformDeclares).uniq().array;
        vertexAst.sentences ~= uniformDeclares.map!(a => cast(Statement)a).array;
        string[] contents;
        contents ~= requires.map!(r => r.getVertexBodyCode()).array;
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
        return format!"gl_Position = %s * vec4(position, 1);"(s.getVertexSpace().getUniformDemands().map!(u => u.getUniformDemandCode()).join(" * "));
    }

    VariableDeclare[] requiredUniform(Ast ast) {
        return ast.getSentence!VariableDeclare()
        .filter!(declare => declare.attributes.has(Attribute.Uniform)).array;
    }

    BlockDeclare[] requiredUniformBlock(Ast ast) {
        return ast.getSentence!BlockDeclare()
        .filter!(s => s.type == BlockType.Uniform).array;
    }

    UniformDemand[] getDependentUniform(Require[] requires, Sharp vertexDeclare) {
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

    Statement[] declareUniform(UniformDemand uniform) {
        Token[] tokens;
        final switch (uniform) {
        case UniformDemand.World:
            tokens = tokenize("uniform mat4 worldMatrix;");
            return [new VariableDeclare(tokens)];
        case UniformDemand.View:
            tokens = tokenize("uniform mat4 viewMatrix;");
            return [new VariableDeclare(tokens)];
        case UniformDemand.Proj:
            tokens = tokenize("uniform mat4 projMatrix;");
            return [new VariableDeclare(tokens)];
        case UniformDemand.Light:
            tokens = tokenize(PointLight.declareCode);
            Statement[] results = [new BlockDeclare(tokens)];
            tokens = tokenize(
                        "uniform LightBlock {
                            int pointLightNum;
                            PointLight pointLights[10];
                        }");
            results ~= new BlockDeclare(tokens);
            return results;
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
