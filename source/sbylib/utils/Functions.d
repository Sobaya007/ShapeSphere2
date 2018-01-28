module sbylib.utils.Functions;

import std.typecons, std.math;
import std.typetuple;

static import std.string;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.character.Label;
import sbylib.wrapper.freetype.Font;
import sbylib.wrapper.freetype.FontLoader;
import sbylib.wrapper.freeimage.Image;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Constants;
import sbylib.camera.Camera;
import sbylib.collision.geometry.CollisionRay;

class Utils {

    static {

        Texture generateTexture(Image image) {
            return new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.RGBA, image.getWidth(), image.getHeight(), ImageFormat.BGRA, image.getBits());
        }

        pure @nogc {
            auto red()    { return vec4(1,0,0,1);}
            auto green()  { return vec4(0,1,0,1);}
            auto blue()   { return vec4(0,0,1,1);}
            auto yellow() { return vec4(1,1,0,1);}
            auto purple() { return vec4(1,0,1,1);}
            auto cyan()   { return vec4(0,1,1,1);}
            auto black()  { return vec4(0,0,0,1);}
            auto white()  { return vec4(1,1,1,1);}
            auto gray()   { return vec4(.5,.5,.5,1);}

            bool contains(T)(T value, T[] array... ) {
                foreach( e; array )
                    if( value == e )
                        return true;
                return false;
            }

            T computeUnSignedArea(T)(Vector!(T,3)[3] positions...) {
                return length(cross(positions[2] - positions[0], positions[1] - positions[0]));
            }

        }

        pure {
            float[] solveLinearEquation(float a, float b) {
                return a == 0 ? null : [-b / a];
            }

            float[] solveQuadraticEquation(float a, float b, float c) {
                if (a == 0) return solveLinearEquation(b,c);
                auto D = b^^2 - 4*a*c;
                float denom = 1 / (2 * a);
                if (D > 0) {
                    D = sqrt(D);
                    return [(-b + D) * denom, (-b - D) * denom];
                } else if (D > -1e-4) {
                    return [-b * denom];
                }
                return null;
            }

            Vector!(T,U)[] expand(T, uint U)(Vector!(T,U)[] vertex, uint[] order) {
                return order.map!(i => vertex[i]).array;
            }

            Vector!(T,U)[] expandQuads(T, uint U)(Vector!(T,U)[] vertex, uint[4][] order) {
                return order.map!(o => [0,1,2,2,1,3].map!(i => o[i]).array).array.join.map!(i => vertex[i]).array;
            }

        }

        //与えられた点列に対し、分散が最大化するベクトルを含む正規直交基底を返す
        Vector!(T,3)[] mostDispersionBasis(T)(Vector!(T,3)[] vertices...) in {
            assert(vertices.length > 0);
        } body {
            import std.algorithm, std.array;
            auto c = vertices.sum / vertices.length;
            mat3 vcm = mat3(0);
            foreach (ref v; vertices) {
                auto r = v.xyz - c;
                vcm += Matrix!(float,3,1)(r.array) * Matrix!(float,1,3)(r.array);
            }
            vcm /= vertices.length;
            auto diagonal = mat3.diagonalizeForRealSym(vcm);
            import std.algorithm, std.range, std.array;
            auto base = 3.iota.map!(a => diagonal.column[a].normalize).array;
            return base;
        }

        T computeSignedVolume(T)(Vector!(T, 3)[4] positions...) {
            mixin({
                string code;
                foreach (i; 0..3) {
                    code ~= "Vector!(T,3) v" ~ to!string(i) ~ " = positions[" ~to!string(i+1) ~ "] - positions[0];\n";
                }
                code ~= "return ";
                foreach (i; 0..3) {
                    code ~= "+v" ~ to!string(i) ~ ".x * v" ~ to!string((i+1)%3) ~ ".y * v" ~ to!string((i+2)%3) ~ ".z\n";
                }
                foreach (i; 0..3) {
                    code ~= "-v" ~ to!string(i) ~ ".x * v" ~ to!string((i+2)%3) ~ ".y * v" ~ to!string((i+1)%3) ~ ".z\n";
                }
                code ~= ";";
                return code;
            }());
            }

            bool or(T)(bool delegate(T) func, T[] elements...) {
                foreach (e; elements) if (func(e)) return true;
                return false;
            }

            bool or(T)(bool function(T) func, T[] elements...) {
                foreach (e; elements) if (func(e)) return true;
                return false;
            }

            bool and(T)(bool delegate(T) func, T[] elements...) {
                foreach (e; elements) if (!func(e)) return false;
                return true;
            }

            vec3 projToView(vec3 projPos, Camera camera) {
                auto projInv = mat4.invert(camera.projMatrix());
                auto row3 = projInv.row[3];

                auto projPos4 = vec4(projPos, 1);
                auto cs = 1 / row3.dot(projPos4);
                return (projInv * projPos4 * cs).xyz;
            }

            void getRay(vec2 screenPos, Camera camera, ref CollisionRay ray) {
                auto viewStart = Utils.projToView(vec3(screenPos, -100), camera);
                auto viewEnd = Utils.projToView(vec3(screenPos, 100), camera);

                mat4 viewInv = camera.worldMatrix;
                auto viewInv3 = viewInv.toMatrix3;

                ray.start = (viewInv * vec4(viewStart, 1)).xyz;
                ray.dir = viewInv3 * normalize(viewEnd - viewStart);
            }

            //deprecated void drawRect(float cx, float cy, float width, float height, vec4 color = white) {
            //    ShaderProgram sp = ShaderStore.getShader("DrawRect");
            //    cx = getX(cx, width);
            //    cy = getY(cy, height);
            //    auto uniformSetting = (CustomObject custom) {
            //        with (custom) {
            //            setUniform!(4, "color")(color.array);
            //            setUniform!(1, "cx")(cx);
            //            setUniform!(1, "cy")(cy);
            //            setUniform!(1, "width")(width);
            //            setUniform!(1, "height")(height);
            //            //setUniform!(1, "ww")(SbyWorld.currentWindow.viewportWidth);
            //            //setUniform!(1, "wh")(SbyWorld.currentWindow.viewportHeight);
            //        }
            //    };
            //    drawWithShader(sp, uniformSetting);
            //}
            //
            //void drawImage(float cx, float cy, float width, float height, TextureObject tex) {
            //    ShaderProgram sp = ShaderStore.getShader("DrawImage");
            //    cx = getX(cx, width);
            //    cy = getY(cy, height);
            //
            //    auto uniformSetting = (CustomObject custom) {
            //        with (custom) {
            //            setUniform!(1, "cx")(cx);
            //            setUniform!(1, "cy")(cy);
            //            setUniform!(1, "width")(width);
            //            setUniform!(1, "height")(height);
            //            //setUniform!(1, "ww")(SbyWorld.currentWindow.viewportWidth);
            //            //setUniform!(1, "wh")(SbyWorld.currentWindow.viewportHeight);
            //            setTexture(tex);
            //        }
            //    };
            //    drawWithShader(sp, uniformSetting);
            //}
            //
            //void drawImageWithColor(float cx, float cy, float width, float height, TextureObject tex, vec4 color = white) {
            //    ShaderProgram sp = ShaderStore.getShader("DrawImageWithColor");
            //    cx = getX(cx, width);
            //    cy = getY(cy, height);
            //
            //    auto uniformSetting = (CustomObject d) {
            //        with (d) {
            //            setUniform!(1, "cx")(cx);
            //            setUniform!(1, "cy")(cy);
            //            setUniform!(1, "width")(width);
            //            setUniform!(1, "height")(height);
            //            //setUniform!(1, "ww")(SbyWorld.currentWindow.viewportWidth);
            //            //setUniform!(1, "wh")(SbyWorld.currentWindow.viewportHeight);
            //            setUniform!(4, "color")(color.array);
            //            setTexture(tex);
            //        }
            //    };
            //    drawWithShader(sp, uniformSetting);
            //}
            //
            ////if you want to fill circle, set thickness 0.
            //void drawCircle(float cx, float cy, float width, float height, float thickness, vec4 color = white) {
            //    ShaderProgram sp = ShaderStore.getShader("DrawCircle");
            //    cx = getX(cx, width);
            //    cy = getY(cy, height);
            //    auto uniformSetting = (CustomObject custom) {
            //        with (custom) {
            //            setUniform!(1, "cx")(cx);
            //            setUniform!(1, "cy")(cy);
            //            setUniform!(1, "width")(width);
            //            setUniform!(1, "height")(height);
            //            //setUniform!(1, "ww")(SbyWorld.currentWindow.viewportWidth);
            //            //setUniform!(1, "wh")(SbyWorld.currentWindow.viewportHeight);
            //            setUniform!(4, "color")(color.array);
            //            setUniform!(1, "thickness")(thickness);
            //        }
            //    };
            //    drawWithShader(sp, uniformSetting);
            //}
            //
            //void drawWithShader(ShaderProgram sp, void delegate(CustomObject) uniformSetting) {
            //    rect.setShaderProgram(sp);
            //    rect.beginMesh;
            //    rect.addAttribute!(2, "mVertex")([-1,-1, +1,-1, -1,+1, +1,+1], GpuSendFrequency.Static);
            //    rect.setIndex([0,1,2,3], GpuSendFrequency.Static);
            //    rect.endMesh();
            //    uniformSetting(rect);
            //    rect.draw();
            //}
            //
            //void drawLine(vec3 p0, vec3 p1, vec4 color = vec4(1,1,1,1)) {
            //    with (line) {
            //        setUniformMatrix!(4, "mWorld")(mat4.identity.array);
            //        //setUniformMatrix!(4, "mViewProj")(SbyWorld.currentCamera.getViewProjectionMatrix.array);
            //        setUniform!(4, "color")(color.array);
            //    }
            //    line.update("mVertex", p0.array ~ 1 ~ p1.array ~ 1);
            //    line.draw;
            //}
            //
            //void drawLine(vec2 p0, vec2 p1, vec4 color = vec4(1,1,1,1)) {
            //    line.setShaderProgram(ShaderStore.getShader("SimpleColor"));
            //    with (line) {
            //        //mat4 mWorld = mat4.translate(-vec3(1, 1, 0)) * mat4.scale(vec3(2.0f / SbyWorld.currentWindow.width, 2.0f / SbyWorld.currentWindow.height, 1));
            //        //setUniformMatrix!(4, "mWorld")(mWorld.array);
            //        //setUniformMatrix!(4, "mViewProj")(mat4.identity.array);
            //        //setUniform!(4, "color")(color.array);
            //    }
            //    line.update("mVertex", p0.array ~ 0 ~ 1 ~ p1.array ~ 0 ~ 1);
            //    line.draw;
            //}
            //
            //void drawText(wstring text, float x, float y, uint size, vec4 color = black, Font font = defaultFont) {
            //    textLabel.setFont(font);
            //    textLabel.setString(text,size);
            //    textLabel.draw(x,y,color);
            //}
            //
            //enum LocationFormatX {
            //    Center, Left, Right
            //}
            //
            //enum LocationFormatY {
            //    Center, Top, Bottom
            //}
            //
            //private LocationFormatX locX = LocationFormatX.Center;
            //private LocationFormatY locY = LocationFormatY.Center;
            //private Tuple!(LocationFormatX, LocationFormatY)[] locStack;
            //
            //void setLocationFormatX(LocationFormatX xf) {
            //    locX = xf;
            //}
            //
            //void setLocationFormatY(LocationFormatY yf) {
            //    locY = yf;
            //}
            //
            //void pushLocationFormat() {
            //    locStack ~= tuple(locX, locY);
            //}
            //
            //void popLocationFormat() {
            //    auto t = locStack[$-1];
            //    locX = t[0];
            //    locY = t[1];
            //    locStack = locStack[0..$-1];
            //}
            //
            //private float getX(float x, float width) {
            //    final switch (locX) {
            //    case LocationFormatX.Center:
            //        return x;
            //    case LocationFormatX.Left:
            //        return x + width/2;
            //    case LocationFormatX.Right:
            //        return x - width/2;
            //    }
            //}
            //
            //private float getY(float y, float height) {
            //    final switch (locY) {
            //    case LocationFormatY.Center:
            //        return y;
            //    case LocationFormatY.Bottom:
            //        return y + height/2;
            //    case LocationFormatY.Top:
            //        return y - height/2;
            //    }
            //}
            //
            //
            //void checkTime(void delegate() func, int limitTime)() {
            //    StopObserved sw;
            //    sw.start;
            //    func();
            //    sw.stop;
            //    //  assert(sw.peek.msecs < limitTime, "Time Limit Exceeded");
            //}
            //
            //ulong getTime(void delegate() func)() {
            //    StopObserved sw;
            //    sw.start;
            //    func();
            //    sw.stop;
            //    return sw.peek.msecs;
            //}

            //@youxkeiさんからのいただきもの
            void print(Args...)(Args args) pure nothrow @nogc @trusted
            {
                import std.stdio : writeln;
                import std.traits : functionLinkage, functionAttributes, FunctionAttribute, SetFunctionAttributes;

                alias WritelnType = typeof(&writeln!Args);
                enum PureNothrowNogcWritelnAttributes = functionAttributes!WritelnType | FunctionAttribute.pure_ | FunctionAttribute.nothrow_ | FunctionAttribute.nogc;

                (cast(SetFunctionAttributes!(WritelnType, functionLinkage!WritelnType, PureNothrowNogcWritelnAttributes))&writeln!Args)(args);
            }
    }

    // Singleton パターン
    mixin template Singleton() {
        private static typeof(this) _instance;
        static typeof(this) opCall() {
            if(_instance is null) _instance = new typeof(this)();
            return _instance;
        }
    }

    template Range(int stop) {
        static if (stop <= 0)
            alias TypeTuple!() Range;
        else
            alias TypeTuple!(Range!(stop-1), stop-1) Range;
    }

    /// ditto
    template Range(int start, int stop) {
        static if (stop <= start)
            alias TypeTuple!() Range;
        else
            alias TypeTuple!(Range!(start, stop-1), stop-1) Range;
    }

    /// ditto
    template Range(int start, int stop, int step) {
        static assert(step != 0, "Range: step must be != 0");

        static if (step > 0) {
            static if (stop <= start)
                alias TypeTuple!() Range;
        else
                alias TypeTuple!(Range!(start, stop-step, step), stop-step) Range;
        } else {
            static if (stop >= start)
                alias TypeTuple!() Range;
        else
                alias TypeTuple!(Range!(start, stop-step, step), stop-step) Range;
        }
    } // End Range!(a,b,c)

    template Range(T, T[] array) {
        static if (array.length == 0) {
            alias Range = TypeTuple!();
        } else {
            alias Range = TypeTuple!(array[0], Range!(T, array[1..$]));
        }
    }

    template include(T, T[] members, T name) {
        static if (members.length == 0) {
            enum include = false;
        } else static if (members[0] == name) {
            enum include = true;
        } else {
            enum include = include!(T, members[1..$], name);
        }
    }
}

bool instanceof(T,S)(S o) if(is(T == class)) {
	return cast(T) o !is null;
}

import std.json, std.traits;
Type as(Type)(JSONValue v) if (isNumeric!Type) {
    switch (v.type) {
        case JSON_TYPE.INTEGER:
            return v.integer();
        case JSON_TYPE.UINTEGER:
            return v.uinteger();
        case JSON_TYPE.FLOAT:
            return v.floating();
        default:
            assert(false);
    }
}

Type as(Type)(JSONValue v) if (isArray!Type) {
    assert(v.type == JSON_TYPE.ARRAY);
    import std.algorithm : map;
    import std.array;
    return v.array().map!(as!(ForeachType!Type)).array;
}

template staticFindIndex(alias F, T...) {
    template _staticFindIndex(alias F, int cnt, T...) {
        static if (T.length == 0) {
            enum _staticFindIndex = -1;
        } else static if (F!(T[0])) {
            enum _staticFindIndex = cnt;
        } else {
            enum _staticFindIndex = _staticFindIndex!(F, cnt+1, T[1..$]);
        }
    }

    enum staticFindIndex = _staticFindIndex!(F, 0, T);
}

template haveMember(Type, string member) {
    import std.meta;
    static if (isAggregateType!Type) {
        static if (Filter!(ApplyLeft!(isSame, member), __traits(allMembers, Type)).length > 0) {
            enum haveMember = true;
        } else static if (is(typeof({Type t; auto po = &t.opDispatch!(member);}))) {
            enum haveMember = true;
        } else static if (__traits(getAliasThis, Type).length > 0) {
            enum This = "Type." ~ __traits(getAliasThis, Type)[0];
            static if (isCallable!(mixin(This))) {
                alias Type2 = ReturnType!(mixin(This));
            } else {
                alias Type2 = typeof(mixin(This));
            }
            enum haveMember = haveMember!(Type2, member);
        } else {
            enum haveMember = false;
        }
    } else static if (isArray!Type) {
        enum haveMember = member == "length";
    } else {
        enum haveMember = false;
    }
}

mixin template Proxy() {
    enum Proxied;

    template opDispatch(string name) {
        import std.traits, std.meta;
        alias Types = typeof(getSymbolsByUDA!(typeof(this), Proxied));
        enum index = staticFindIndex!(ApplyRight!(haveMember, name), Types);
        static if (index >= 0) {
            alias TargetType = Types[index];
            enum MemberCall = getSymbolsByUDA!(typeof(this), Proxied)[index].stringof ~ "." ~ name;
            static if (is(typeof(__traits(getMember, TargetType, name)) == function)) {
                // non template function
                auto opDispatch(this X, Args...)(Args args) {
                    return mixin(MemberCall ~ "(args)");
                }
            } else static if (is(typeof({ enum x = mixin(MemberCall); }))) {
                // built-in type field, manifest constant, and static non-mutable field
                enum opDispatch = mixin(MemberCall);
            } else static if (is(typeof(mixin(MemberCall))) || __traits(getOverloads, TargetType, name).length != 0) {
                // field or property function
                @property auto ref opDispatch() {
                    return mixin(MemberCall);
                }
            } else {
                // member template
                template opDispatch(T...)
                {
                    enum targs = T.length ? "!T" : "";
                    auto ref opDispatch(this X, Args...)(auto ref Args args){
                        return mixin(MemberCall ~ targs ~ "(args)");
                    }
                }
            }
        }
    }
}
