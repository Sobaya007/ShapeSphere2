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


class GlslUtils {
static:

    Ast completeFragmentAST(Ast fragAst) {
        fragAst.completeColorOutput();
        fragAst.completeVersionDeclare();
        return fragAst;
    }

    Ast completeGeometryAST(Ast geomAst, Ast fragAst) {
        alias append = a => geomAst.statements ~= a.map!(s => cast(Statement)s).array;

        geomAst.completeVersionDeclare();

        geomAst.addRequiredGeometryInVariableDeclares(fragAst);
        geomAst.addRequiredOutVariableDeclares(fragAst);
        geomAst.addRequiredUniformVaribleDeclares(fragAst);

        geomAst.getStatements!(VariableDeclare)
            .filter!(v => v.attributes.has(Attribute.In))
            .each!(v => v.replaceID(s => "g"~s));

        append(
            fragAst.getStatements!(RequireAttribute)
                .map!((r) {
                    auto v = new VariableDeclare(r.variable.getCode());
                    v.replaceID(_ => "g"~getAttributeDemandName(r.attr));
                    return new RequireAttribute(r.attr, Space.Local, v);
                })
                .array
        );

        geomAst.addEmitVertexDeclare(fragAst);

        geomAst.getStatements!(RequireAttribute)
            .each!(r => r.isInFragment = false);

        return geomAst;
    }

    Ast generateVertexAST(Ast previousAst) {
        Ast vertexAst = new Ast;

        vertexAst.completeVersionDeclare();
        vertexAst.addRequiredVertexInVariableDeclares(previousAst);
        vertexAst.addRequiredOutVariableDeclares(previousAst);
        vertexAst.addRequiredUniformVaribleDeclares(previousAst);
        vertexAst.addVertexMainFunction(previousAst);

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
}
