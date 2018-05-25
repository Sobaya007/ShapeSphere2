module sbylib.material.Material;

public {
    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.material.RenderConfig;
}

class Material {

    import sbylib.wrapper.gl;
    import sbylib.material.glsl;
    import sbylib.utils.Functions;

    Program program;
    private static Program[TypeInfo] programs;
    @Proxied RenderConfig config;
    TypedUniform!int debugCounter;

    mixin Proxy;

    this() {
        if (auto program = typeid(this) in programs) {
            this.program = *program;
        } else {
            this.program = new Program(getShaders);
            programs[typeid(this)] = this.program;
        }
        this.config = new RenderConfig();
        this.debugCounter = new TypedUniform!int("DebugCounter");
    }

    void destroy() {
        this.program.destroy();
    }

    final void set(const(Uniform) delegate()[] uniforms) {
        this.config.set();
        static Program before;
        if (before !is program) {
            before = program;
            this.program.use();
        }
        import std.stdio;
        import std.algorithm;
        this.program.applyUniform(uniforms.map!(u=>u()));
    }

    void initialize() {}

    abstract void replaceUniformName(string delegate(string));
    abstract const(UniformDemand[]) getUniformDemands();
    protected abstract Shader[] getShaders();
    abstract const(Uniform) delegate()[] getUniforms();

    mixin template commonDeclare(bool vertexShaderAutoGen) {
;
        import sbylib.material.glsl;
        import sbylib.wrapper.gl;

        private static UniformDemand[] demands;
        private static Shader vertexShader, fragmentShader;

        private static void initializeShader() {
            auto fragAST = generateFragmentAST();
            auto vertAST = vertexShaderAutoGen ? GlslUtils.generateVertexAST(fragAST) : new Ast(readText(getVertexPath()));
            demands = GlslUtils.requiredUniformDemands([vertAST, fragAST]);
            vertexShader = new Shader(vertAST.getCode(), ShaderType.Vertex);
            fragmentShader = new Shader(fragAST.getCode(), ShaderType.Fragment);
        }

        override const(UniformDemand[]) getUniformDemands() {
            if (!demands) initializeShader();
            return demands;
        }

        protected override Shader[] getShaders() {
            if (!demands) initializeShader();
            return [vertexShader, fragmentShader];
        }

        private static string autoAssignCode() {
            import std.traits, std.format;
            string str;
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    enum name = FieldNameTuple!(typeof(this))[i];
                    str ~= format!q{
                        this.%s = new %s("%s");
                    }(name, type.stringof, name);
                }
            }}
            return str;
        }

        override string toString() {
            import sbylib.utils.Functions;
            return typeof(this).stringof;
        }

        invariant {
            import std.traits;
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    enum name = FieldNameTuple!(typeof(this))[i];
                    mixin(format!q{
                        assert(this.%s !is null, "%s is null.");
                    }(name, name));
                }
            }}
        }
    }

    mixin template declare(bool vertexShaderAutoGen = true, string file = __FILE__) {
        import std.file, std.path, std.string;
        import sbylib.utils.Path;
        import sbylib.material.glsl;


        alias getVertexPath = () => ShaderPath(baseName(file).replace(".d", ".vert"));
        alias getFragmentPath = () => ShaderPath(baseName(file).replace(".d", ".frag"));

        alias config this;

        mixin commonDeclare!(vertexShaderAutoGen);

        static Ast generateFragmentAST() {
            import sbylib.material.glsl;
            auto fragSource = readText(getFragmentPath());
            auto fragAST = GlslUtils.generateFragmentAST(new Ast(fragSource));
            return fragAST;
        }

        override void replaceUniformName(string delegate(string) replacer) {
            import std.traits;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    auto u = &mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                    u.setName(replacer(u.getName));
                }
            }
        }

        override const(Uniform) delegate()[] getUniforms() {
            import std.traits;
            const(Uniform) delegate()[] result;
            enum FieldName = FieldNameTuple!(typeof(this));
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    enum name = FieldName[i];
                    const Uniform u = mixin(name);
                    assert(u !is null, FieldName[i] ~ " is null.");
                    result ~= () => cast(const(Uniform))mixin(name);
                }
            }}
            return result;
        }

        template hasMember(string mem) {
            import sbylib.utils.Functions;
            enum hasMember = hasDirectMember!(typeof(this), mem);
        }
    }

    mixin template declareMix(A, B, string file = __FILE__) {
        import std.file, std.path, std.string;
        import sbylib.utils.Path;
        import sbylib.material.glsl;

        alias getVertexPath = () => ShaderPath(baseName(file).replace(".d", ".vert"));
        alias getFragmentPath = () => ShaderPath(baseName(file).replace(".d", ".frag"));

        alias config this;

        mixin commonDeclare!(true);

        private A a;
        private B b;

        static Ast generateFragmentAST() {
            Ast[] fragASTs;
            auto ast1 = A.generateFragmentAST();
            ast1.name = MaterialName1;
            fragASTs ~= ast1;
            auto ast2 = B.generateFragmentAST();
            ast2.name = MaterialName2;
            fragASTs ~= ast2;
            auto mainAst = GlslUtils.generateFragmentAST(new Ast(readText(getFragmentPath())));
            mainAst.name = "main";
            auto fragAST = GlslUtils.mergeASTs(fragASTs ~ mainAst);
            fragAST = GlslUtils.generateFragmentAST(fragAST);
            return fragAST;
        }

        override void initialize() {
            this.a = new A;
            this.b = new B;

            this.a.initialize();
            this.b.initialize();

            string pascal(string s) {
                import std.conv;
                return capitalize(to!string(s[0])) ~ s[1..$];
            }
            this.a.replaceUniformName((string s) => MaterialName1 ~ pascal(s));
            this.b.replaceUniformName((string s) => MaterialName2 ~ pascal(s));
        }

        override void replaceUniformName(string delegate(string) replacer) {
            import std.traits;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    auto u = mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                    u.setName(replacer(u.getName));
                }
            }
            this.a.replaceUniformName(replacer);
            this.b.replaceUniformName(replacer);
        }

        override const(Uniform) delegate()[] getUniforms() {
            import std.traits;
            const(Uniform) delegate()[] result;
            enum FieldName = FieldNameTuple!(typeof(this));
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    enum name = FieldName[i];
                    const Uniform u = mixin(name);
                    assert(u !is null, FieldName[i] ~ " is null.");
                    result ~= () => cast(const(Uniform))mixin(name);
                }
            }}
            result ~= a.getUniforms;
            result ~= b.getUniforms;
            return result;
        }

        template opDispatch(string mem) if (hasMember!(mem)) {
            import sbylib.utils.Functions;
            enum hasMemberThis = hasDirectMember!(typeof(this), mem);
            enum hasMemberA = hasDirectMember!(typeof(this.a), mem);
            enum hasMemberB = hasDirectMember!(typeof(this.b), mem);
            static if (hasMemberThis) {
                enum MemberCall = "this." ~ mem;
            } else static if (!hasMemberThis && hasMemberA && !hasMemberB) {
                enum MemberCall = "this.a." ~ mem;
            } else static if (!hasMemberThis && !hasMemberA && hasMemberB) {
                enum MemberCall = "this.b." ~ mem;
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
                        enum MemberCall = "this.a." ~ mem2;
                    } else static if (hit == '2') {
                        enum MemberCall = "this.b." ~ mem2;
                    } else {
                        static assert(false);
                    }
                }
            }

            auto ref opDispatch(Args...)(auto ref Args args) {
                return mixin(MemberCall ~ "= args");
            }

            auto ref opDispatch() {
                return mixin(MemberCall);
            }
        }

        template hasMember(string mem) {
            import sbylib.utils.Functions;
            enum hasMemberThis = hasDirectMember!(typeof(this), mem);
            enum hasMemberA = hasDirectMember!(A, mem);
            enum hasMemberB = hasDirectMember!(B, mem);
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
                        enum hasMember = A.hasMember!mem2;
                    } else static if (hit == '2') {
                        enum hasMember = B.hasMember!mem2;
                    } else {
                        enum hasMember = false;
                    }
                }
            }
        }
    }
}
