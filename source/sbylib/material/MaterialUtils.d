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

        static Ast generateFragmentAST() {
            auto fragSource = readText(FRAG_ROOT);
            auto fragAST = GlslUtils.generateFragmentAST(new Ast(fragSource));
            return fragAST;
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
            foreach (u; this.getUniforms) {
                assert(u, "Uniform variable must be initialized");
                u.setName(replace(u.getName()));
            }
        }

        template hasMember(string s) {
            import sbylib.utils.Functions;
            enum hasMember = Utils.hasMember!(typeof(this), s);
        }
    }

    mixin template declareMix(alias A, alias B, string file = __FILE__) {

        import std.string;
        import std.file;
        import std.traits;
        import sbylib.material.glsl.Ast;
        import sbylib.material.glsl.GlslUtils;
        enum FRAG_ROOT = file.replace(".d", ".frag");
        private A.Keeper a;
        private B.Keeper b;

        static Ast generateFragmentAST() {
            Ast[] fragASTs;
            auto ast1 = A.Keeper.generateFragmentAST();
            ast1.name = MaterialName1;
            fragASTs ~= ast1;
            auto ast2 = B.Keeper.generateFragmentAST();
            ast2.name = MaterialName2;
            fragASTs ~= ast2;
            auto mainAst = GlslUtils.generateFragmentAST(new Ast(readText(FRAG_ROOT)));
            mainAst.name = "main";
            auto fragAST = GlslUtils.mergeASTs(fragASTs ~ mainAst);
            fragAST = GlslUtils.generateFragmentAST(fragAST);
            return fragAST;
        }

        override Uniform[] getUniforms() {
            Uniform[] result;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (isAssignable!(Uniform, type)) {
                    result ~= mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                }
            }
            result ~= this.a.getUniforms();
            result ~= this.b.getUniforms();
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

            string pascal(string s) {
                import std.conv;
                return capitalize(to!string(s[0])) ~ s[1..$];
            }
            this.a = new A.Keeper(mat, s => replace(MaterialName1 ~ pascal(s)));
            this.b = new B.Keeper(mat, s => replace(MaterialName2 ~ pascal(s)));
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (isAssignable!(Uniform, type)) {
                    auto u = mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                    u.setName(replace(u.getName()));
                }
            }
        }

        ref auto opDispatch(string mem)() if (hasMember!mem) {
            import sbylib.utils.Functions;
            enum hasMemberThis = Utils.hasMember!(typeof(this), mem);
            enum hasMemberA = Utils.hasMember!(typeof(this.a), mem);
            enum hasMemberB = Utils.hasMember!(typeof(this.b), mem);
            static if (hasMemberThis) {
                return mixin("this." ~ mem);
            } else static if (!hasMemberThis && hasMemberA && !hasMemberB) {
                return mixin("this.a." ~ mem);
            } else static if (!hasMemberThis && !hasMemberA && hasMemberB) {
                return mixin("this.b." ~ mem);
            } else {
                import std.ascii;
                import std.conv;
                import std.algorithm;
                enum pos = mem.countUntil!isDigit;
                static if (pos == -1) {
                    static assert(false);
                } else {
                    enum mem2 = mem[0..pos] ~ mem[pos+1..$];
                    enum hit = mem[pos];
                    static if (hit == '1') {
                        return mixin("this.a." ~ mem2);
                    } else static if (hit == '2') {
                        return mixin("this.b." ~ mem2);
                    } else {
                        static assert(false);
                    }
                }
            }
        }

        template hasMember(string mem) {
            import sbylib.utils.Functions;
            enum hasMemberThis = Utils.hasMember!(typeof(this), mem);
            enum hasMemberA = Utils.hasMember!(typeof(this.a), mem);
            enum hasMemberB = Utils.hasMember!(typeof(this.b), mem);
            static if (hasMemberThis) {
                enum hasMember = true;
            } else static if (!hasMemberThis && hasMemberA && !hasMemberB) {
                enum hasMember = true;
            } else static if (!hasMemberThis && !hasMemberA && hasMemberB) {
                enum hasMember = true;
            } else {
                import std.ascii;
                import std.conv;
                import std.algorithm;
                enum pos = mem.countUntil!isDigit;
                static if (pos == -1) {
                    enum hasMember = false;
                } else {
                    enum mem2 = mem[0..pos] ~ mem[pos+1..$];
                    enum hit = mem[pos];
                    static if (hit == '1') {
                        enum hasMember = typeof(this.a).hasMember!mem2;
                    } else static if (hit == '2') {
                        enum hasMember = typeof(this.b).hasMember!mem2;
                    } else {
                        enum hasMember = false;
                    }
                }
            }
        }
    }
}
