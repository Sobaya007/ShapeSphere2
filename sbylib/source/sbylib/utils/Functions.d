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
import sbylib.core.Core;
import sbylib.core.World;


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
    private static __gshared bool _singletonInitialized;
    public static typeof(this) opCall() {
        if (!_singletonInitialized) {
            _singletonInitialized = true;
        }
        if(_instance is null) _instance = new typeof(this)();
        return _instance;
    }
}

bool instanceof(T,S)(S o) if(is(T == class)) {
	return cast(T) o !is null;
}

template as(Type) {
    import std.json, std.traits;
    import sbylib.math.Angle;

    static if (is(Type == enum)) {
        Type as(JSONValue v) {
            import std.conv;
            return v.as!(string).to!Type;
        }
    } else static if (is(Type == JSONValue[])) {
        Type as(JSONValue v) {
            return v.array;
        }
    } else static if (is(Type == bool)) {
        Type as(JSONValue v) {
            switch (v.type) {
                case JSON_TYPE.TRUE:
                    return true;
                case JSON_TYPE.FALSE:
                    return false;
                default:
                    assert(false);
            }
        }
    } else static if (isNumeric!Type) {
        Type as(JSONValue v) {
            switch (v.type) {
                case JSON_TYPE.INTEGER:
                    return cast(Type)v.integer();
                case JSON_TYPE.UINTEGER:
                    return cast(Type)v.uinteger();
                case JSON_TYPE.FLOAT:
                    return cast(Type)v.floating();
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
        Type as(JSONValue v) 
            in(v.type == JSON_TYPE.ARRAY)
        {
            import std.algorithm : map;
            import std.array;
            return v.array().map!(as!(ForeachType!Type)).array;
        }
    } else static if (isInstanceOf!(Vector, Type)) {
        Type as(JSONValue v) {
            return Type(v.as!(float[]));
        }
    } else static if (is(Type == Degree)) {
        Type as(JSONValue v) {
            return v.as!(float).deg;
        }
    } else static if (is(Type == Radian)) {
        Type as(JSONValue v) {
            return v.as!(float).rad;
        }
    } else static if (is(Type == JSONValue[string])) {
        Type as(JSONValue v) 
            in(v.type == JSON_TYPE.OBJECT)
        {
            return v.object;
        }
    } else {
        static assert(false);
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

template Reduce(alias F, T...) {
    static assert(T.length > 0);
    static if (T.length == 1) {
        alias Reduce = T[0];
    } else {
        alias Reduce = F!(T[0], Reduce!(F, T[1..$]));
    }
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
    auto bpp = image.getBPP();
    ImageInternalFormat internalFormat;
    ImageFormat imageFormat;
    switch (bpp) {
        case 8:
            internalFormat = ImageInternalFormat.R;
            imageFormat = ImageFormat.R;
            break;
        case 8*4:
            internalFormat = ImageInternalFormat.RGBA;
            imageFormat = ImageFormat.BGRA;
            break;
        default:
            assert(false, "mendoi");
    }
    return new Texture(TextureTarget.Tex2D, 0, internalFormat, image.getWidth(), image.getHeight(), imageFormat, image.getBits());
}

Image generateImage(Texture texture) {
    import sbylib.wrapper.gl.Functions;
    auto img = new Image(texture.width, texture.height, GlUtils.getBitPerPixel(texture.internalFormat));
    texture.blitsTo(img.getBits, ImageFormat.BGRA);
    return img;
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
    T array;
    private size_t mWidth, mHeight;
    private bool flip;

    this(size_t w, size_t h) {
        this.mWidth = w;
        this.mHeight = h;
        this.array.length = w * h;
    }

    this(T array, size_t w, size_t h) {
        this.array = array;
        this.mWidth = w;
        this.mHeight = h;
    }

    auto opBinary(string op, U)(U value) if (is(typeof(this) == U)) {
        alias R = typeof(mixin("array[0]"~op~"value.array[0]"));
        R[] result = new R[this.array.length];
        foreach (i; 0..this.array.length) {
            result[i] = mixin("this.array[i]"~op~"value.array[i]");
        }
        return RectangleBuffer!(R[])(result, this.width, this.height);
    }

    auto opBinary(string op, U)(U value) if (!is(typeof(this) == U)) {
        alias R = typeof(mixin("array[0]"~op~"value"));
        R[] result = new R[this.array.length];
        foreach (i; 0..this.array.length) {
            result[i] = mixin("this.array[i]"~op~"value");
        }
        return RectangleBuffer!(R[])(result, this.width, this.height);
    }

    void opOpAssign(string op, U)(RectangleBuffer!(U) value) 
    {
        foreach (i; 0..this.array.length) {
            mixin("this.array[i]"~op~"=value.array[i];");
        }
    }

    auto opIndex(long x, long y) 
        in(0 <= x && x < width)
        in(0 <= y && y < height)
    {
        if (flip) y = height-y-1;
        return array[x+y*width];
    }

    auto opIndex(SliceObject a, SliceObject b) 
        in(0 <= a.begin && a.begin < width)
        in(0 <= b.begin && b.begin < height)
        in(0 <= a.end   && a.end   < width)
        in(0 <= b.end   && b.end   < height)
        in(a.begin <= a.end)
        in(b.begin <= b.end)
    {
        auto result = typeof(this)(a.end-a.begin, b.end-b.begin);
        foreach (i; a.begin..a.end) {
            foreach (j; b.begin..b.end) {
                result[i-a.begin, j-b.begin] = this[i,j];
            }
        }
        return result;
    }

    void opIndexAssign(U)(U value, long x, long y) 
        in(0 <= x && x < width)
        in(0 <= y && y < height)
    {
        array[x+y*width] = value;
    }

    void opIndexOpAssign(string op, U)(U value, long x, long y) 
        in(0 <= x && x < width)
        in(0 <= y && y < height)
    {
        if (flip) y = height-y-1;
        mixin("array[x+y*width]"~op~"= value;");
    }

    import std.conv : to;
    void opIndexAssign(U)(U value, SliceObject a, SliceObject b) 
        in(0 <= a.begin && a.begin <  width)
        in(0 <= b.begin && b.begin <  height)
        in(0 <= a.end   && a.end   <= width)
        in(0 <= b.end   && b.end   <= height)
        in(a.begin <= a.end)
        in(b.begin <= b.end)
    {
        static if (is(typeof(this) == U)) {
            assert(a.end - a.begin == value.width);
            assert(b.end - b.begin == value.height);
        }
        foreach (i; a.begin..a.end) {
            foreach (j; b.begin..b.end) {
                static if (is(typeof(this) == U)) {
                    this[i,j] = value[i-a.begin,j-b.begin];
                } else {
                    this[i,j] = value;
                }
            }
        }
    }

    auto width() {
        return mWidth;
    }

    auto height() {
        return mHeight;
    }

    auto ptr() {
        return array.ptr;
    }

    auto getArray() {
        return array;
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

    auto opIndex(SliceObject x, size_t y) 
        in(0 <= x.begin && x.begin < width)
        in(0 <= x.end   && x.end   < width)
        in(0 <= y       && y       < height)
        in(x.begin <= x.end)
    {
        if (flip) y = height-y-1;
        return array[y*width+x.begin..y*width+x.end];
    }

    auto opIndexAssign(S[] value, SliceObject x, size_t y) 
        in(0 <= x.begin && x.begin < width)
        in(0 <= x.end   && x.end   < width)
        in(0 <= y       && y       < height)
        in(x.begin <= x.end)
    {
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

    auto opIndex(long x, long y) 
        in(0 <= x && x < width)
        in(0 <= y && y < height)
    {
        return rect[x+ox,y+oy];
    }

    void opIndexAssign(S value, long x, long y) 
        in(0 <= x && x < width)
        in(0 <= y && y < height)
    {
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
    return RectangleBuffer!T(array[0..width*height], width, height);
}

import sbylib.render.RenderTarget;
void blitsTo(Texture texture, IRenderTarget dst, int x, int y, int w, int h) {
    import sbylib.core.Window;
    static RenderTarget[Window] target;
    auto window = Window.getCurrentWindow();
    if (window !in target) {
        target[window] = new RenderTarget(texture.width(), texture.height());
    } else {
        if (target[window].width != texture.width()
            || target[window].height != texture.height()) {
            target[window].destroy();
            target[window] = new RenderTarget(texture.width, texture.height);
        }
        auto t = target[window];
        t.attachTexture(texture, FramebufferAttachType.Color0);
        t.blitsTo(dst, x, y, w, h, ClearMode.Color);
    }
}

void blitsTo(Texture texture, IRenderTarget dst) {
    blitsTo(texture, dst, 0, 0, dst.width, dst.height);
}

auto createRenderer2D(World world, IRenderTarget target = Core().getWindow().getScreen()) {
    import sbylib;
    auto camera = new PixelCamera;
    world.setCamera(camera);
    return new Renderer(world, target, new AutoFitViewport);
}

void configure2D(World world, IRenderTarget target = Core().getWindow().getScreen()) {
    import sbylib;

    auto renderer = createRenderer2D(world, target);
    Core().addProcess({
        target.clear(ClearMode.Color, ClearMode.Depth, ClearMode.Stencil);
        renderer.render();
    }, "render");
}

auto createRenderer3D(World world, Camera camera, IRenderTarget target = Core().getWindow().getScreen()) {
    import sbylib;
    world.setCamera(camera);
    return new Renderer(world, target, new AspectFixViewport(Core().getWindow()));

}

void configure3D(World world, Camera camera, IRenderTarget target = Core().getWindow().getScreen()) {
    import sbylib;

    auto renderer = createRenderer3D(world, camera, target);
    Core().addProcess({
        target.clear(ClearMode.Color, ClearMode.Depth, ClearMode.Stencil);
        renderer.render();
    }, "render");
}

mixin template ImplPositionSetter(alias width, alias height) {
    
    float left(float value) {
        this.pos.x = value + width/2;
        return value;
    }

    float right(float value) {
        this.pos.x = value - width/2;
        return value;
    }

    float top(float value) {
        this.pos.y = value - height/2;
        return value;
    }

    float bottom(float value) {
        this.pos.y = value + height/2;
        return value;
    }
}

void screenShot(string path) {
    auto target = new RenderTarget(Core().getWindow().width, Core().getWindow().height);
    target.attachTexture!(uint)(FramebufferAttachType.Color0);
    Core().getWindow().getScreen().blitsTo(target, BufferBit.Color);
    target.getColorTexture().generateImage().save(path);
    target.destroy();
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
