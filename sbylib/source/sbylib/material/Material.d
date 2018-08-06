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
    import sbylib.entity.Entity : ID;

    Program program;
    @Proxied RenderConfig config;

    protected static int ID_SEED = 0;

    mixin Proxy;

    this() {
        this.program = new Program(getShaders);
        this.config = new RenderConfig();
    }

    final void set(const(Uniform) delegate()[] uniforms) {
        this.config.set();
        this.program.use();
        import std.algorithm;
        this.program.beginUniform();
        this.program.applyUniform(uniforms.map!(u=>u()));
        this.applyUniforms(this.program);
        this.program.endUniform();
    }

    void initialize() {}

    abstract void replaceUniformName(string delegate(string));
    abstract const(UniformDemand[]) getUniformDemands();
    protected abstract Shader[] getShaders();
    abstract void applyUniforms(Program);
    abstract ID getID();

    mixin template commonDeclare(string configStr) {

        import std.string : split;
        import std.array : front, empty;
        import std.algorithm : find;
        import std.traits : EnumMembers;
        import std.format;
        import std.json;
        import sbylib.utils.Path;
        import sbylib.material.glsl;
        import sbylib.wrapper.gl;
        import sbylib.utils.Maybe; 
        import sbylib.utils.Functions : as; 

        enum ConfigKey {
            VertexShaderAutoGen = "vertexShaderAutoGen",
            BaseName = "baseName",
            UseGeometryShader = "useGeometryShader"
        };
        enum parsed = parseJSON(configStr);

        static assert(parsed.type == JSON_TYPE.OBJECT, "Argument is not an object");

        static auto getConfig(T)(ConfigKey key, T defaultValue) {
            import std.conv;
            return wrapException(parsed[key].as!T).getOrElse(defaultValue);
        }

        enum VertexShaderAutoGen = getConfig(ConfigKey.VertexShaderAutoGen, true);
        enum BaseName = getConfig(ConfigKey.BaseName, typeof(this).stringof.split("!").front);
        enum UseGeometryShader = getConfig(ConfigKey.UseGeometryShader, false);

        static foreach (key; parsed.object.keys) {
            static assert([EnumMembers!(ConfigKey)].find(key).empty == false, 
                    format!"%s: '%s' is not a valid key"(typeof(this).stringof, key));
        }


        alias getVertexPath = () => ShaderPath(BaseName ~ ".vert");
        alias getGeometryPath = () => ShaderPath(BaseName ~ ".geom");
        alias getFragmentPath = () => ShaderPath(BaseName ~ ".frag");

        alias config this;

        private UniformDemand[] demands;
        private Shader vertexShader, fragmentShader;
        TypedUniform!int _id;

        static if (UseGeometryShader) {
            private Shader geomtryShader;
        }

        private void initializeShader() {
            import std.file : readText;
            static if (UseGeometryShader) {
                auto fragAST = generateFragmentAST();
                fragAST.addIdOutput();
                auto geomAST = new Ast(readText(getGeometryPath()));
                geomAST = GlslUtils.completeGeometryAST(geomAST, fragAST);
                auto vertAST = VertexShaderAutoGen ? GlslUtils.generateVertexAST(geomAST) : new Ast(readText(getVertexPath()));
                demands = GlslUtils.requiredUniformDemands([vertAST, geomAST, fragAST]);
                vertexShader = new Shader(vertAST.getCode(), ShaderType.Vertex);
                geomtryShader = new Shader(geomAST.getCode(), ShaderType.Geometry);
                fragmentShader = new Shader(fragAST.getCode(), ShaderType.Fragment);
            } else {
                auto fragAST = generateFragmentAST();
                fragAST.addIdOutput();
                auto vertAST = VertexShaderAutoGen ? GlslUtils.generateVertexAST(fragAST) : new Ast(readText(getVertexPath()));
                demands = GlslUtils.requiredUniformDemands([vertAST, fragAST]);
                vertexShader = new Shader(vertAST.getCode(), ShaderType.Vertex);
                fragmentShader = new Shader(fragAST.getCode(), ShaderType.Fragment);
            }
        }

        override const(UniformDemand[]) getUniformDemands() {
            if (!demands) initializeShader();
            return demands;
        }

        protected override Shader[] getShaders() {
            if (!demands) initializeShader();
            static if (UseGeometryShader) return [vertexShader, geomtryShader, fragmentShader];
            else return [vertexShader, fragmentShader];
        }

        private static string autoAssignCode() {
            import std.traits;
            import std.format;
            string str;
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                enum name = FieldNameTuple!(typeof(this))[i];
                static if (isUniformAssignable!(type)) {
                    str ~= format!q{
                        this.%s = new %s("%s");
                    }(name, type.stringof, name);
                } else static if (isArray!(type) && isUniformAssignable!(ForeachType!(type))) {
                    str ~= format!q{
                        foreach (j, ref elem; %s) { 
                            import std.conv : to;
                            elem = new %s("%s[" ~ j.to!string ~ "]");
                        }
                    }(name, ForeachType!(type).stringof, name);
                }
            }}
            str ~= q{this._id = new TypedUniform!int("_id"); };
            str ~= q{this._id = ID_SEED++; };
            return str;
        }

        override string toString() {
            import sbylib.utils.Functions;
            return typeof(this).stringof;
        }

        import sbylib.entity.Entity : ID;
        override ID getID() {
            return this._id.get();
        }

        invariant {
            import std.traits, std.format;
            static foreach (i, type; FieldTypeTuple!(typeof(this))) {{
                static if (is(typeof({const(Uniform) u = type.init;}))) {
                    enum name = FieldNameTuple!(typeof(this))[i];
                    mixin(format!q{
                        assert(this.%s !is null, "%s is null.");
                    }(name, name));
                }
            }}
        }

        private void applyThisUniforms(Program program) {
            import std.traits;
            import std.range : only;
            enum FieldName = FieldNameTuple!(typeof(this));
            static foreach (i, Type; FieldTypeTuple!(typeof(this))) {{
                enum name = FieldName[i];
                static if (is(typeof({const(Uniform) u = Type.init;}))) {
                    const(Uniform) u = mixin(name);
                    program.applyUniform(u);
                } else static if (isArray!(Type) || isAssociativeArray!(Type)) {
                    alias ElementType = ForeachType!(Type);
                    static if (is(typeof({const(Uniform) u = ElementType.init;}))) {
                        foreach (val; mixin(name)) {
                            program.applyUniform(val);
                        }
                    }
                }
            }}
        }

        private enum isUniformAssignable(T) = is(typeof({const(Uniform) u = T.init;}));
    }

    mixin template ConfigureMaterial(string configStr="{}") {
        import std.file : readText;
        import sbylib.material.glsl;
        import sbylib.wrapper.gl.Program;

        mixin commonDeclare!(configStr);

        static Ast generateFragmentAST() {
            import sbylib.material.glsl;
            auto fragSource = readText(getFragmentPath());
            auto fragAST = GlslUtils.completeFragmentAST(new Ast(fragSource));
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

        override void applyUniforms(Program program) {
            applyThisUniforms(program);
        }

        template hasMember(string mem) {
            import sbylib.utils.Functions;
            enum hasMember = hasDirectMember!(typeof(this), mem);
        }
    }

    mixin template ConfigureMixMaterial(A, B, string configStr="{}") {
        import sbylib.material.glsl;
        import sbylib : Program;

        mixin commonDeclare!(configStr);

        private A a;
        private B b;

        static Ast generateFragmentAST() {
            import std.file : readText;
            Ast[] fragASTs;
            auto ast1 = A.generateFragmentAST();
            ast1.name = MaterialName1;
            fragASTs ~= ast1;
            auto ast2 = B.generateFragmentAST();
            ast2.name = MaterialName2;
            fragASTs ~= ast2;
            auto mainAst = GlslUtils.completeFragmentAST(new Ast(readText(getFragmentPath())));
            mainAst.name = "main";
            auto fragAST = GlslUtils.mergeASTs(fragASTs ~ mainAst);
            fragAST = GlslUtils.completeFragmentAST(fragAST);
            return fragAST;
        }

        override void initialize() {
            this.a = new A;
            this.b = new B;

            this.a.initialize();
            this.b.initialize();

            string pascal(string s) {
                import std.conv;
                import std.string : capitalize;
                
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

        override void applyUniforms(Program program) {
            applyThisUniforms(program);
            a.applyUniforms(program);
            b.applyUniforms(program);
        }

        template opDispatch(string mem) if (hasMember!(mem)) {
            import sbylib.utils.Functions;
            enum hasMemberConfig = hasDirectMember!(RenderConfig, mem);
            enum hasMemberThis = hasDirectMember!(typeof(this), mem);
            enum hasMemberA = hasDirectMember!(typeof(this.a), mem);
            enum hasMemberB = hasDirectMember!(typeof(this.b), mem);
            static if (hasMemberConfig) {
                enum MemberCall = "this.config." ~ mem;
            } else static if (hasMemberThis) {
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

            auto ref opDispatch(Args)(auto ref Args args) {
                return mixin(MemberCall ~ "= args");
            }

            auto ref opDispatch() {
                return mixin(MemberCall);
            }
        }

        template hasMember(string mem) {
            import sbylib.utils.Functions;
            enum hasMemberConfig = hasDirectMember!(RenderConfig, mem);
            enum hasMemberThis = hasDirectMember!(typeof(this), mem);
            enum hasMemberA = hasDirectMember!(A, mem);
            enum hasMemberB = hasDirectMember!(B, mem);
            static if (hasMemberConfig) {
                enum hasMember = true;
            } else static if (hasMemberThis) {
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
