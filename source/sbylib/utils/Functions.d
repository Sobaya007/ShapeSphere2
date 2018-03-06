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

//@youxkeiさんからのいただきもの
void print(Args...)(Args args) pure nothrow @nogc @trusted
{
    import std.stdio : writeln;
    import std.traits : functionLinkage, functionAttributes, FunctionAttribute, SetFunctionAttributes;

    alias WritelnType = typeof(&writeln!Args);
    enum PureNothrowNogcWritelnAttributes = functionAttributes!WritelnType | FunctionAttribute.pure_ | FunctionAttribute.nothrow_ | FunctionAttribute.nogc;

    (cast(SetFunctionAttributes!(WritelnType, functionLinkage!WritelnType, PureNothrowNogcWritelnAttributes))&writeln!Args)(args);
}

// Singleton パターン
mixin template Singleton() {
    private static __gshared typeof(this) _instance;
    public static typeof(this) opCall() {
        if(_instance is null) _instance = new typeof(this)();
        return _instance;
    }
}

bool instanceof(T,S)(S o) if(is(T == class)) {
	return cast(T) o !is null;
}

template as(Type) {
    import std.json, std.traits;

    static if (isNumeric!Type) {
        Type as(JSONValue v) {
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
    } else static if (isSomeString!(Type)) {
        import std.conv;
        Type as(JSONValue v) {
            switch (v.type) {
                case JSON_TYPE.STRING:
                    return v.str().to!(Type);
                default:
                    assert(false);
            }
        }
    } else static if (isArray!(Type)) {
        Type as(JSONValue v) {
            assert(v.type == JSON_TYPE.ARRAY);
            import std.algorithm : map;
            import std.array;
            return v.array().map!(as!(ForeachType!Type)).array;
        }
    }
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

template hasDirectMember(Type, string member) {
    import std.meta, std.traits;
    enum hasDirectMember = Filter!(ApplyLeft!(isSame, member), __traits(allMembers, Type)).length > 0;
}

template haveMember(Type, string member) {
    import std.meta, std.traits;
    static if (isAggregateType!Type) {
        static if (hasMember!(Type, member)) {
            enum haveMember = true;
        } else static if (__traits(getAliasThis, Type).length > 0) {
            enum This = "Type." ~ __traits(getAliasThis, Type)[0];
            static if (isCallable!(mixin(This))) {
                alias Type2 = ReturnType!(mixin(This));
            } else {
                alias Type2 = typeof(mixin(This));
            }
            enum haveMember = haveMember!(Type2, member);
        //} else static if (isFunction!(mixin(member)) && isImplicitlyConvertible!(Type, Parameters!(mixin(member))[0])) {
            //enum haveMember = true;
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
        static assert(index >= 0);
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

mixin template buildReadonly(Type, string name) {
    import std.format;
    mixin(format!q{
              private Type %s;

              auto %s() inout {
                  return %s;
              }
          }("_"~name, name, "_"~name));
}

Texture generateTexture(Image image) {
    return new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.RGBA, image.getWidth(), image.getHeight(), ImageFormat.BGRA, image.getBits());
}

string indent(string str, int space) {
    import std.string, std.algorithm, std.range;
    return str.split("\n").map!(s => " ".repeat(space).join ~ s).join("\n");
}

private struct SliceObject {
    size_t begin, end;
}

struct RectangleBuffer(T) {
    import sbylib.utils.Maybe;
    import std.traits;
    alias S = ForeachType!(T);
    private T array;
    private size_t width, height;
    private bool flip;

    auto opIndex(long x, long y) {
        if (x < 0) return None!S;
        if (y < 0) return None!S;
        if (x >= width) return None!S;
        if (y >= height) return None!S;
        if (flip) y = height-y-1;
        return Just(array[x+y*width]);
    }

    void opIndexAssign(S value, long x, long y) {
        if (x < 0) return;
        if (y < 0) return;
        if (x >= width) return;
        if (y >= height) return;
        if (flip) y = height-y-1;
        array[x+y*width] = value;
    }

    auto slice(size_t ox, size_t oy, size_t w, size_t h) {
        return RectangleBufferSlice!T(this, ox, oy, w, h);
    }

    auto flipY() {
        flip = !flip;
        return this;
    }

    auto opSlice(size_t idx)(size_t begin, size_t end) {
        return SliceObject(begin, end);
    }

    auto opIndex(SliceObject x, size_t y) {
        if (flip) y = height-y-1;
        return array[y*width+x.begin..y*width+x.end];
    }

    auto opIndexAssign(S[] value, SliceObject x, size_t y) {
        if (flip) y = height-y-1;
        array[y*width+x.begin..y*width+x.end] = value;
    }
}

struct RectangleBufferSlice(T) {
    import sbylib.utils.Maybe;
    import std.traits;
    alias S = ForeachType!(T);
    private RectangleBuffer!T rect;
    private size_t ox, oy, width, height;

    auto opIndex(long x, long y) {
        if (x < 0) return None!S;
        if (y < 0) return None!S;
        if (x >= width) return None!S;
        if (y >= height) return None!S;
        return rect[x+ox,y+oy];
    }

    void opIndexAssign(S value, long x, long y) {
        if (x < 0) return;
        if (y < 0) return;
        if (x >= width) return;
        if (y >= height) return;
        rect[x+ox,y+oy] = value;
    }

    auto opSlice(size_t idx)(size_t begin, size_t end) {
        return rect.opSlice!(idx)(begin+ox, end+ox);
    }

    auto opIndex(SliceObject x, size_t y) {
        return rect.opIndex(x,y+oy);
    }

    auto opIndexAssign(S[] value, SliceObject x, size_t y) {
        rect.opIndexAssign(value, x, y+oy);
    }
}

auto asRect(T)(T array, size_t width, size_t height) {
    return RectangleBuffer!T(array, width, height);
}

enum red    = vec4(1,0,0,1);
enum green  = vec4(0,1,0,1);
enum blue   = vec4(0,0,1,1);
enum yellow = vec4(1,1,0,1);
enum purple = vec4(1,0,1,1);
enum cyan   = vec4(0,1,1,1);
enum black  = vec4(0,0,0,1);
enum white  = vec4(1,1,1,1);
enum gray   = vec4(.5,.5,.5,1);
