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
import sbylib.material.glsl.RequireUniform;
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

    Ast[2] generateAstFromFragmentSource(string fragSource) {
        auto tokens = tokenize(fragSource);
        auto fragAst = new Ast(tokens);
        auto vertAst = createVertexShaderAst(fragAst);
        if (!fragAst.hasColorOutput()) {
            fragAst.statements = new VariableDeclare("out vec4 fragColor;") ~ fragAst.statements;
        }
        if (!fragAst.hasVersion()) {
            fragAst.statements = new Sharp("#version 400") ~ fragAst.statements;
        }
        return [vertAst, fragAst];
    }

    UniformDemand[] requiredUniformDemands(Ast[] asts) {
        return asts.map!(ast => ast.getStatements!RequireUniform()
                .map!(ru => ru.uni).array ~
                (ast.getStatements!RequireAttribute() ~
                    ast.getStatements!Sharp()
                    .filter!(sharp => sharp.type == "vertex")
                    .map!(sharp => sharp.getRequireAttribute()).array)
                .map!(ra => ra.space.getUniformDemands()).join())
        .join().sort().uniq().array;
    }

    Ast createVertexShaderAst(Ast fragmentAst) {
        Ast vertexAst = new Ast;

        //Pull fragment #vertex
        Sharp vertexDeclare = pullVertexDeclare(fragmentAst);

        RequireAttribute[] requires = fragmentAst.getStatements!RequireAttribute();
        RequireAttribute positionRequireAttribute = vertexDeclare.getRequireAttribute();

        //Add Version
        if (!vertexAst.hasVersion()) {
            vertexAst.statements ~= new Sharp("#version 400");
        }

        //Add vertex in declare
        auto vertexIn = (requires ~ positionRequireAttribute).map!(v => v.getVertexIn()).array;
        vertexIn = vertexIn
        .sort!((a,b) => a.getCode() <  b.getCode())
        .uniq!((a,b) => a.getCode() == b.getCode())
        .array;
        vertexAst.statements ~= vertexIn;

        //Add vertex out declare
        vertexAst.statements ~= requires.map!(r => r.getVertexOut()).array;

        //Add vertex uniform declare
        auto dependentUniforms = (requires ~ positionRequireAttribute).map!(r => r.space.getUniformDemands()).join().sort().uniq().array;
        auto uniformDeclares = dependentUniforms.map!(u => getUniformDemandDeclare(u)).join();
        vertexAst.statements ~= uniformDeclares;

        //Add main function
        string[] contents;
        contents ~= requires.map!(r => r.getVertexBodyCode()).array;
        contents ~= vertexDeclare.getGlPositionCode();
        auto tokens = tokenize(format!"void main() {\n  %s\n}"(contents.join("\n  ")));
        vertexAst.statements ~= new FunctionDeclare(tokens);
        return vertexAst;
    }

    Sharp pullVertexDeclare(Ast ast) {
        auto statements = ast.getStatements!Sharp().filter!(sharp => sharp.type == "vertex").array;
        assert(statements.length != 0, "#vertex declare is required.");
        assert(statements.length <= 1, "#vertex declare must be only one.");
        return statements[0];
    }
}

unittest {
    import std.stdio, std.file;
    auto file = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto asts = GlslUtils.createShaders(file);
    writeln(asts[1].getCode());
    writeln(GlslUtils.getUniformNames(asts));
}
