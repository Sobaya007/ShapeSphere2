module sbylib.utils.Functions;

import std.typecons, std.math;

static import std.string;
import sbylib.utils;
import sbylib.character;
import sbylib.math;
import sbylib.gl;
import sbylib.shadertemplates;
import sbylib.core;
import sbylib.setting;
import sbylib.loader;

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

    //与えられた点列に対し、分散が最大化するベクトルを含む正規直交基底を返す
    Vector!(T,3)[] mostDispersionBasis(T)(Vector!(T,3)[] vertices...) {
        vec3 c = vec3(0);
        uint vNum = 0;
        foreach (ref v; vertices) {
            c += v;
            vNum++;
        }
        assert(vNum);
        c /= vNum;
        mat3 vcm = mat3(0);
        foreach (ref v; vertices) {
            auto r = v.xyz - c;
            vcm += Matrix!(float,3,1)(r.array) * Matrix!(float,1,3)(r.array);
        }
        vcm /= vNum;
        auto diagonal = mat3.diagonalizeForRealSym(vcm);
        auto base = 3.iota.map!(a => diagonal.column(a).normalize).array;
        return base;
    }

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

void sbyWrite(alias v)() {
    writeln(v.stringof, "=", v);
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

//private CustomObject rect;
//private CustomObject line;
private Label textLabel;
private Font defaultFont;

void initFunctions() {
//    rect = new CustomObject(null, Prim.TriangleStrip);
//
//    line = new CustomObject(ShaderStore.getShader("SimpleColor"), Prim.Line);
//    line.beginMesh;
//    line.addAttribute!(4, "mVertex")([0,0,0,1,10,10,0,1], GpuSendFrequency.Static);
//    line.setIndex([0,1], GpuSendFrequency.Static);
//    line.endMesh;

    defaultFont = FontLoader.load(ROOT_PATH ~ "Resource/meiryo.ttc", FontType.AntiAlias, 50);

    textLabel = new Label(defaultFont);
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
//    StopWatch sw;
//    sw.start;
//    func();
//    sw.stop;
//    //  assert(sw.peek.msecs < limitTime, "Time Limit Exceeded");
//}
//
//ulong getTime(void delegate() func)() {
//    StopWatch sw;
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

mixin template CreateSetter(alias vary, string setterExtCode = "") {
    @property {
        mixin("void " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "_(" ~ typeof(vary).stringof ~ " " ~ vary.stringof ~ ") {"
                 ~ "this." ~ vary.stringof ~ " = " ~ vary.stringof ~ ";" ~ setterExtCode ~ "}");
    }
}

mixin template CreateGetter(alias vary, string getterExtCode = "") {
    @property {
        mixin(typeof(vary).stringof ~ " " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "() {"
                 ~ getterExtCode
                 ~ "return " ~ vary.stringof ~ ";}");
    }
}

mixin template CreateSetterGetter(alias vary, string setterExtCode = "", string getterExtCode = "") {
    static import std.string;
    @property {
        mixin("void " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "(" ~ typeof(vary).stringof ~ " " ~ vary.stringof ~ ") {"
                 ~ "this." ~ vary.stringof ~ " = " ~ vary.stringof ~ ";" ~ setterExtCode ~ "}");
        mixin(typeof(vary).stringof ~ " " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "() {"
                 ~ getterExtCode
                 ~ "return " ~ vary.stringof ~ ";}");
    }
}

mixin template CacheVar(alias trigger, alias target, string updateFunc) {
    static if (!__traits(hasMember, typeof(this), target.stringof ~ "_update_flag")) {
        mixin("private bool " ~ target.stringof ~ "_update_flag = true;");
    }
    @property {
        //triggerのsetterを宣言
        mixin Createsetter!(trigger, target.stringof ~ "_update_flag = true;");
        //triggerのgetterを宣言
        mixin Creategetter!(trigger, "");
        mixin Createsetter!(target, "");
        //targetのgetterを宣言
        mixin Creategetter!(
                target,
                "if (" ~ target.stringof ~ "_update_flag) {"
                 ~ target.stringof ~ "_update_flag = false;"
                 ~ target.stringof ~ " = " ~ updateFunc ~ "();}"
                );
    }
}

// Singleton パターン
template singleton(T ...) {
    static typeof(this) opCall(T t) {
        static typeof(this) instance;
        if(!instance) instance = new typeof(this)(t);
        return instance;
    }
}
