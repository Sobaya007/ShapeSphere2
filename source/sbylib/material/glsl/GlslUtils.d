module sbylib.material.glsl.GlslUtils;

import std.string;
import std.algorithm;
import std.conv;
import std.traits;
import std.range;
import std.typecons;
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

    Ast generateFragmentAST(Ast fragAst) {
        if (!fragAst.hasColorOutput()) {
            fragAst.statements = new VariableDeclare("out vec4 fragColor;") ~ fragAst.statements;
        }
        if (!fragAst.hasVersion()) {
            fragAst.statements = new Sharp("#version 400") ~ fragAst.statements;
        }
        return fragAst;
    }

    Ast generateVertexAST(Ast fragmentAst) {
        Ast vertexAst = new Ast;

        // fragment #vertex
        Sharp vertexDeclare = fragmentAst.getVertexDeclare();

        RequireAttribute[] requires = fragmentAst.getStatements!RequireAttribute();
        RequireAttribute positionRequireAttribute = vertexDeclare.getRequireAttribute();

        //Add Version
        vertexAst.statements ~= new Sharp("#version 400");

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

    Ast mergeASTs(Ast[] asts) {
        // modify AST
        string pascal(string s) {
            if (s.length == 0) return "";
            return capitalize(to!string(s[0])) ~ s[1..$];
        }
        asts = asts.map!((ast) {
            if (ast.name == "main") return ast;
            ast.outParameterIntoMain();
            ast.getMainFunction().id = "";
            ast.replaceID(str => ast.name ~ pascal(str));
            return ast;
        }).array;
        auto vertex = asts.map!(ast => ast.getStatements!Sharp().filter!(sharp => sharp.type == "vertex")).join;
        auto variables = asts.map!(ast => ast.getStatements!VariableDeclare).join;
        auto requireAttributes = asts.map!(ast => ast.getStatements!RequireAttribute).join;
        auto requireUniforms = asts.map!(ast => ast.getStatements!RequireUniform).join;
        auto blocks = asts.map!(ast => ast.getStatements!BlockDeclare).join;
        auto functions = asts.map!(ast => ast.getStatements!FunctionDeclare).join;

        assert(vertex.all!(v => vertex[0].value == v.value), "Vertex Space differs between ASTs");
        requireUniforms = requireUniforms.sort!((a,b) => a.getCode() < b.getCode()).uniq!((a,b) => a.getCode() == b.getCode()).array;
        Ast ast = new Ast;
        alias append = a => ast.statements ~= a.map!(s => cast(Statement)s).array;
        ast.statements ~= cast(Statement)vertex[0];
        append(requireAttributes);
        append(requireUniforms);
        append(variables);
        append(blocks);
        append(functions);
        return ast;
    }
}

unittest {
    import std.stdio, std.file;
    auto file1 = readText("./source/sbylib/material/lambert/LambertMaterial.frag");
    auto file2 = readText("./source/sbylib/material/normal/NormalMaterial.frag");
    auto frag1 = GlslUtils.generateFragmentAST(new Ast(file1));
    auto frag2 = GlslUtils.generateFragmentAST(new Ast(file2));
    frag1.name = "A";
    frag2.name = "B";
    auto merged = GlslUtils.mergeASTs([frag1, frag2]);
    writeln(merged.getCode());
}
