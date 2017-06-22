module sbylib.math.Vector;

import std.algorithm;
import std.range;
import std.conv;
import std.math;
import std.string;
import std.stdio;
import std.format;
import std.array;
import std.traits;

alias Vector!(float, 2) vec2; //========================================適当にaliasしとく
alias Vector!(float, 3) vec3;
alias Vector!(float, 4) vec4;
alias Vector!(int,   2) vec2i;
alias Vector!(int,   3) vec3i;
alias Vector!(int,   4) vec4i;

//T型のS個のベクトル
struct Vector(T, uint S) if (__traits(isArithmetic, T)) {
private:
    T[S] elements;
public:

    enum dimension = S;
    enum type = T.stringof;
    @nogc {

        this(T e) {
            elements[] = e;
        }

        this(T[] elements...) {
            this.elements[] = elements[0..S];
        }

        this(Args...)(Args args) {
            auto cnt = 0;
            foreach (arg; args) {
                static if (isArray!(typeof(arg))) {
                    this.elements[cnt..cnt+arg.length] = arg;
                    cnt += arg.length;
                    //isInstanceOfでやろうとしたが、この時点ではVectorの型情報が正しく作られていないため参照できない。
                } else static if (__traits(compiles, typeof(arg).dimension) && __traits(hasMember, typeof(arg), "opIndex")) {
                    this.elements[cnt..cnt+arg.elements.length] = arg.elements;
                    cnt += arg.elements.length;
                } else static if (isAssignable!(T, typeof(arg))) {
                    this.elements[cnt] = arg;
                    cnt++;
                } else {
                    static assert(false, typeof(arg));
                }
            }
        }


        Vector opBinary(string op)(const Vector v) const //=============================Vectorに対する二項演算
         in {
            assert(S == v.elements.length);
        }
body {
            Vector!(T, S) result;
            mixin("result.elements[] = elements[]" ~ op ~ "v.elements[];");
            return result;
        }

        Vector opBinary(string op)(T t) const { //================================スカラーに対する二項演算
            Vector!(T, S) result;
            mixin("result.elements[] = elements[]" ~ op ~ "t;");
            return result;
        }

        Vector opBinaryRight(string op)(T t) {
            Vector!(T, S) result;
            mixin("result.elements[] = t" ~ op ~ "elements[];");
            return result;
        }

        Vector opUnary(string op)() const { //====================================単項演算子
            Vector!(T, S) result;
            mixin(getUnaryCode(op, S));
            return result;
        }

        void opOpAssign(string op)(Vector v) //=============================ベクトルに対する代入算術演算子
         in {
            assert(v.elements.length == S);
        }
body {
            mixin("elements[] " ~ op ~"= v.elements[];");
        }

        void opOpAssign(string op)(T e) { //================================スカラーに対する代入算術演算子
            mixin("elements[] " ~ op ~"= e;");
        }

        T opIndex(int idx) const { //=========================================添字演算子
            return this.elements[idx];
        }

        T opIndexAssign(T value, size_t idx) {
            return this.elements[idx] = value;
        }

        T opIndexOpAssign(string op)(T value, size_t idx) {
            mixin("return this.elements[idx] " ~ op ~ "= value;");
        }

        auto array() inout { //===================================================配列化
            return elements;
        }

        ref auto opDispatch(string s, Args...)(Args args)
        if (s.all!(a => countUntil("xyzw", a) != -1)
            || s.all!(a => countUntil("rgba", a) != -1)){
            enum isXYZW = s.all!(a => countUntil("xyzw", a) != -1);
            enum isRGBA = s.all!(a => countUntil("rgba", a) != -1);
            enum propertyString = isXYZW ? "xyzw" : isRGBA ? "rgba" : "";
            static assert(propertyString.length > 0);
            static if(Args.length == 0) {
                //getter
                static if(s.length == 1) {
                    enum xyzwPos = countUntil(propertyString, s);
                    return elements[xyzwPos];
                } else {
                    enum index = s.map!(a => countUntil(propertyString, a)).array;
                    Vector!(T, s.length) result;
                    foreach (i,idx; index) {
                        result[i] = elements[idx];
                    }
                    return result;
                }
            } else static if (Args.length == 1) {
                //setter
                alias val = args[0];
                static if(s.length == 1) {
                    enum xyzwPos = countUntil(propertyString, s);
                    return this[xyzwPos] = val;
                } else {
                    static assert(s.length == val.array.length);
                    enum index = s.map!(a => countUntil(propertyString, a)).array;
                    foreach (i,idx; index) {
                        this[idx] = val[i];
                    }
                    return val;
                }
            } else {
                static assert(false);
            }
        }
    }

    string toString() const { //=============================================文字列化
        string code = "(";
        foreach (i; 0..S) {
            code ~= to!string(this[i]);
            if (i != S-1) code ~= ",";
        }
        code ~= ")";
        return code;
    }

    static if (isFloatingPoint!T) {
        bool hasNaN() const {
            alias gen = {
                string code;
                foreach (i; 0..S) {
                    code ~= "if(elements[" ~ to!string(i) ~ "].abs is T.nan) return true;";
                }
                code ~= "return false;";
                return code;
            };
            mixin(gen());
        }
    }
    static Vector fromString(string str) { //===========================文字列からVectorを生成
        Vector r;
        auto strs = str.split[2].split(",");
        foreach (int c, s; strs) {
            r[c] = to!T(s);
        }
        return r;
    }
}

//======================================================================以下ベクトル計算系の関数達

template Assignable(T,S){

    static if (isAssignable!(T, S)) {
        alias Result = T;
        alias Other = S;
    } else static if (isAssignable!(S, T)) {
        alias Result = S;
        alias Other = T;
    }
}

template dot(T, S, uint U) {

    static if (isAssignable!(T, S)) {
        alias Result = T;
        alias Other = S;
    } else static if (isAssignable!(S, T)) {
        alias Result = S;
        alias Other = T;
    }

    Result dot(Vector!(T, U) v, Vector!(S, U) v2) {
        Result result;
        mixin({
            string code = "result = ";
            foreach (i; 0..U) {
                code ~= format!"+v.elements[%d] * v2.elements[%d]"(i,i);
            }
            code ~= ";";
            return code;
        }());
        return result;
    }
}

template minVector(T, S, uint U) {

    mixin Assignable!(T,S);
    Vector!(Result, U) minVector(Vector!(T,U) v, Vector!(S,U) v2) {
        mixin({
            string str = "return Vector!(Result,U)(";
            foreach (i; 0..U) {
                str ~= format!"min(v[%d], v2[%d])"(i,i);
                if (i < U-1) str ~= ",";
            }
                return str ~ ");";
        }());
    }
}

template maxVector(T, S, uint U) {

    mixin Assignable!(T,S);
    Vector!(Result, U) maxVector(Vector!(T,U) v, Vector!(S,U) v2) {
        mixin({
            string str = "return Vector!(Result,U)(";
            foreach (i; 0..U) {
                str ~= format!"max(v[%d], v2[%d])"(i,i);
                if (i < U-1) str ~= ",";
            }
                return str ~ ");";
        }());
    }
}

template cross(T, S, uint U) if (U == 2) {

    static if (isAssignable!(T, S)) {
        alias Result = T;
        alias Other = S;
    } else static if (isAssignable!(S, T)) {
        alias Result = S;
        alias Other = T;
    }

    Result cross(Vector!(T, U) v, Vector!(S, U) v2){
        return v.x * v2.y - v.y * v2.x;
    }
}

template cross(T, S, uint U) if (U == 3) {

    static if (isAssignable!(T, S)) {
        alias Result = T;
        alias Other = S;
    } else static if (isAssignable!(S, T)) {
        alias Result = S;
        alias Other = T;
    }

    Vector!(Result, U) cross(Vector!(T, U) v, Vector!(S, U) v2) {
        Vector!(Result, U) result;
        mixin({
            string code;
            foreach (i; 0..U) {
                code ~= format!"result[%d] = v[%d] * v2[%d] - v[%d] * v2[%d];"(i,(i+1)%3,(i+2)%3,(i+2)%3,(i+1)%3);
            }
            return code;
        }());
        return result;
    }
}


T length(T, int S)(Vector!(T, S) v) {
    mixin({
        string code = "T result = sqrt(";
        foreach (i; 0..S) {
            code ~= format!"+v[%d] * v[%d]"(i,i);
        }
        code ~= ");";
        return code;
    }());
    return result;
}

T lengthSq(T, int S)(Vector!(T, S) v) {
    mixin({
        string code = "T result = ";
        foreach (i; 0..S) {
            code ~= format!"+v[%d] * v[%d]"(i,i);
        }
        code ~= ";";
        return code;
    }());
    return result;
}

Vector!(T, S) normalize(T, int S)(Vector!(T, S) v) {
    mixin({
        string code = "T length = sqrt(";
        foreach (i; 0..S) {
            code ~= format!"+v[%d] * v[%d]"(i,i);
        }
        code ~= ");";
        code ~= "Vector!(T, S) result;";
        foreach (i; 0..S) {
            code ~= format!"result[%d] = v[%d] / length;"(i,i);
       }
            return code;
    }());
    return result;
}

Vector!(T,S) safeNormalize(T, int S)(Vector!(T,S) v) {
    if (mixin({
            string code;
            foreach (i; 0..S) {
                code ~= format!"v.elements[%d] == 0"(i);
                if (i < S-1) code ~= "&&";
            }
                return code;
        }())) return Vector!(T,S)(0);
    return normalize(v);
}

Vector!(T,S) reduceV(alias pred, T, int S)(Vector!(T,S)[] v...) {
    Vector!(T,S) result = v[0];
    foreach (i; 0..S) {
        foreach (j; 1..v.length) {
            result.elements[i] = pred(result.elements[i], v[j].elements[i]);
        }
    }
    return result;
}

private string getUnaryCode(string op, int S) {
    string code;
    foreach (i; 0..S) {
        code ~= "result.elements[" ~ to!string(i) ~ "] = " ~ op ~ "elements[" ~ to!string(i) ~ "];";
    }
    return code;
}

private static string getXyzwCode(uint[] xyzwPos) {
    string code;
    foreach (pos; xyzwPos) {
        code ~= format!"result[i] = this[%d];"(pos);
    }
    return code;
}


unittest {
    vec2 a = vec2(1,2);
    vec2 b = vec2(2,1);
    assert(a.xy == vec2(1,2));
    assert(a.xy == b.yx);
    vec3 c;
    c.yxz = vec3(3,2,1);
    assert(c.zx == a);

    assert(vec4(vec2(1), vec2(2)) == vec4(1,1,2,2));

    assert(vec3(1) == vec3(1,1,1));

    vec2 d = vec2(2,1);
    d.xy = d.yx;
    assert(d.xy == vec2(1,2));
}
