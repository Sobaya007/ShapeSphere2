module sbylib.material.MaterialUtils;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Program;
import sbylib.setting;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.Ast;
import std.file;

class MaterialUtils {

    private this(){}

    static {
        const(Shader) createShaderFromPath(string path, ShaderType type) {
            path = ROOT_PATH ~ path;
            auto source = readText(path);
            return new Shader(source, type);
        }

        const(Program) createProgramFromPath(string vertPath, string fragPath, string geomPath = null) {
            auto vert = createShaderFromPath(vertPath, ShaderType.Vertex);
            auto frag = createShaderFromPath(fragPath, ShaderType.Fragment);
            auto shaders = [vert, frag];
            if (geomPath) {
                auto geom = createShaderFromPath(geomPath, ShaderType.Geometry);
                shaders ~= geom;
            }
            return new Program(shaders);
        }
    }

    mixin template declare(string file = __FILE__) {
        import std.string;
        import std.file;
        import sbylib.material.glsl.Ast;
        import sbylib.material.glsl.GlslUtils;
        enum FRAG_ROOT = file.replace(".d", ".frag");

        static Ast[2] generateASTs() {
            auto fragSource = readText(FRAG_ROOT);
            auto fragAST = GlslUtils.generateFragmentAST(new Ast(fragSource));
            auto vertAST = GlslUtils.generateVertexAST(fragAST);
            return [vertAST, fragAST];
        }

        override Uniform[] getUniforms() {
            import std.traits;
            Uniform[] result;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (isAssignable!(Uniform, type)) {
                    result ~= mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                }
            }
            return result;
        }

        this(Material mat) {
            this(mat, s => s);
        }

        this(Material mat, string delegate(string) replace) {
            static if(__traits(hasMember, typeof(this), "constructor")) {
                constructor();
            }
            foreach (uni; this.getUniforms) {
                uni.setName(replace(uni.getName()));
                mat.setUniform(() => uni);
            }
        }
    }

    mixin template declareMix(alias A, alias B, string file = __FILE__) {

        import std.string;
        import std.file;
        import sbylib.material.glsl.Ast;
        import sbylib.material.glsl.GlslUtils;
        enum FRAG_ROOT = file.replace(".d", ".frag");
        private A.Keeper a;
        private B.Keeper b;

        static Ast[2] generateASTs() {
            Ast[] fragASTs;
            auto ast1 = GlslUtils.generateFragmentAST(new Ast(readText(A.Keeper.FRAG_ROOT)));
            ast1.name = MaterialName1;
            fragASTs ~= ast1;
            auto ast2 = GlslUtils.generateFragmentAST(new Ast(readText(B.Keeper.FRAG_ROOT)));
            ast2.name = MaterialName2;
            fragASTs ~= ast2;
            auto mainAst = GlslUtils.generateFragmentAST(new Ast(readText(FRAG_ROOT)));
            mainAst.name = "main";
            auto fragAST = GlslUtils.mergeASTs(fragASTs ~ mainAst);
            fragAST = GlslUtils.generateFragmentAST(fragAST);
            auto vertAST = GlslUtils.generateVertexAST(fragAST);
            import std.stdio;
//            writeln(vertAST.getCode());
            //writeln(fragAST.getCode());
            return [vertAST, fragAST];
        }

        override Uniform[] getUniforms() {
            import std.traits;
            import std.meta;
            import std.algorithm;
            import std.range;
            import std.array;
            import sbylib.utils.Functions;
            bool have(A,B)(string name) {
                alias nameA = FieldNameTuple!(A);
                bool res = false;
                foreach (n; nameA) {
                    if (name == n) {
                        res = true;
                        break;
                    }
                }
                alias nameB = FieldNameTuple!(B);
                foreach (n; nameB) {
                    if (name == n) {
                        res = true;
                        break;
                    }
                }
                return res;
            }
            Uniform[] result;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (isAssignable!(Uniform, type)) {
                    enum name = FieldNameTuple!(typeof(this))[i];
                    static if(have!(A.Keeper, B.Keeper)(name)) {
                        result ~= mixin("this." ~ name ~ "0");
                    } else {
                        result ~= mixin("this." ~ name);
                    }
                }
            }
            foreach (i, type; FieldTypeTuple!(A.Keeper)) {
                static if (isAssignable!(Uniform, type)) {
                    enum name = FieldNameTuple!(A.Keeper)[i];
                    static if (have!(typeof(this), B.Keeper)(name)) {
                        result ~= mixin("this." ~ name ~ "1");
                    } else {
                        result ~= mixin("this." ~ name);
                    }
                }
            }
            foreach (i, type; FieldTypeTuple!(B.Keeper)) {
                static if (isAssignable!(Uniform, type)) {
                    enum name = FieldNameTuple!(B.Keeper)[i];
                    static if (have!(typeof(this), A.Keeper)(name)) {
                        result ~= mixin("this." ~ name ~ "2");
                    } else {
                        result ~= mixin("this." ~ name);
                    }
                }
            }
            return result;
        }

        this(Material mat) {
            this(mat, s => s);
        }

        this(Material mat, string delegate(string) replace) {
            import std.meta;
            static if(staticIndexOf!("constructor",  __traits(allMembers, typeof(this))) != -1) {
                mixin("this.constructor();");
            }
            this.a = new A.Keeper(mat, s => MaterialName1 ~ capitalize(s));
            this.b = new B.Keeper(mat, s => MaterialName2 ~ capitalize(s));
            foreach (uni; this.getUniforms()) {
                (u) { //謎回避
                    mat.setUniform(() => u);
                }(uni);
            }
        }

        ref auto opDispatch(string s)() {
//            static assert(!__traits(hasMember, this, s) || !__traits(hasMember, this.a, s), "cannot specify member. please add suffix '0', '1' or '2'");
//            static assert(!__traits(hasMember, this, s) || !__traits(hasMember, this.b, s), "cannot specify member. please add suffix '0', '1' or '2'");
//            static assert(!__traits(hasMember, this.a, s) || !__traits(hasMember, this.b, s), "cannot specify member. please add suffix '0', '1' or '2'");
            static if (__traits(hasMember, this.a, s)) {
                return mixin("this.a." ~ s);
            } else static if (__traits(hasMember, this.b, s)) {
                return mixin("this.b." ~ s);
            } else static if (s[$-1] == '0' && __traits(hasMember, this, s[0..$-1])) {
                return mixin("this." ~ s[0..$-1]);
            } else static if (s[$-1] == '1' && __traits(hasMember, this.a, s[0..$-1])) {
                return mixin("this.a." ~ s[0..$-1]);
            } else static if (s[$-1] == '2' && __traits(hasMember, this.b, s[0..$-1])) {
                return mixin("this.b." ~ s[0..$-1]);
            } else {
                static assert(false);
            }
        }
    }
}
