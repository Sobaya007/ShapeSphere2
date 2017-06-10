module sbylib.math.Vector;

import std.algorithm;
import std.range;
import std.conv;
import std.math;
import std.string;
import std.stdio;

string toString(int i) {
    if (i == 0) return "0";
    char[] s;
    while (i > 0) {
        s ~= cast(char)('0' + i % 10);
        i /= 10;
    }
    string r;
    foreach_reverse (c; s) r ~= c;
    return r;
}

bool contains(T)(T value, T[] array... ) {
    foreach( e; array )
        if( value == e )
            return true;
    return false;
}


//T型のS個のベクトル
struct Vector(T, uint S) if (__traits(isArithmetic, T)) {
public:

    enum dimension = S;
    enum type = T.stringof;
    T[S] elements;
    @nogc {

        mixin(getConstructorCode(S)); //====================================コンストラクタの宣言

        this(T e) {
            elements[] = e;
        }

        this(T[] elements) {
            this.elements[] = elements[0..S];
        }

        static if (S <= 4) {
            @property {
                mixin(getXyzwCode("xyzw", S)); //=======================================GLSLっぽくするためのプロパティの宣言
                mixin(getXyzwCode("rgba", S));
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

        ref T opIndex(int idx) { //=========================================添字演算子
            return elements[idx];
        }

        auto array() { //===================================================配列化
            return elements;
        }
    }

    string toString() { //=============================================文字列化
        mixin({
            string code = "return \"(\" ~ ";
            foreach (i; 0..S) {
                code ~= "to!string(elements[" ~ to!string(i) ~ "]) ~";
                if (i != S-1) code ~= " \",\"~";
            }
                code ~= "\")\";";
                return code;
        }());
    }

    import std.traits;
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

alias Vector!(float, 2) vec2; //========================================適当にaliasしとく
alias Vector!(float, 3) vec3;
alias Vector!(float, 4) vec4;
alias Vector!(int,   2) vec2i;
alias Vector!(int,   3) vec3i;
alias Vector!(int,   4) vec4i;

//======================================================================以下ベクトル計算系の関数達

template Assignable(T,S){
    import std.traits;

    static if (isAssignable!(T, S)) {
        alias Result = T;
        alias Other = S;
    } else static if (isAssignable!(S, T)) {
        alias Result = S;
        alias Other = T;
    }
}

template dot(T, S, uint U) {

    import std.traits;

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
                code ~= "+v.elements[" ~ to!string(i) ~ "] * v2.elements[" ~ to!string(i) ~ "]";
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
                str ~= "min(v[" ~ i.to!string ~ "], v2[" ~ i.to!string ~ "])";
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
                str ~= "max(v[" ~ i.to!string ~ "], v2[" ~ i.to!string ~ "])";
                if (i < U-1) str ~= ",";
            }
                return str ~ ");";
        }());
    }
}

template cross(T, S, uint U) if (U == 2) {
    import std.traits;

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
    import std.traits;

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
                code ~= "result[" ~ to!string(i) ~ "] = v.elements[" ~ to!string((i+1)%3) ~
                    "] * v2.elements[" ~ to!string((i+2)%3) ~ "] - v.elements[" ~
                    to!string((i+2)%3) ~ "] * v2.elements[" ~ to!string((i+1)%3) ~ "];";
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
            code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
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
            code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
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
            code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
        }
        code ~= ");";
        code ~= "Vector!(T, S) result;";
        foreach (i; 0..S) {
            code ~= "result.elements[" ~ to!string(i) ~ "] = v.elements[" ~ to!string(i) ~ "] / length;";
        }
            return code;
    }());
    return result;
}

Vector!(T,S) safeNormalize(T, int S)(Vector!(T,S) v) {
    if (mixin({
            string code;
            foreach (i; 0..S) {
                code ~= "v.elements[" ~ to!string(i) ~ "] == 0";
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



//========================================================================以下mixin用の関数達

string getConstructorCode(int S) {
    string r;
    void rec(int[] a, int j, int i) {
        //現在選択中なのがa,今j番目の選択を迫られている。仕切りは全部でi本
        if (a.length == i) {
            //選択終了。処理に入る。
            //いまaの区切りがある。
            int argCount = 0;
            int[] b;
            r ~= "this(";
            foreach (k; 0..i) {
                int elemNum = a[k] - (k == 0 ? -1 : a[k-1]); //引数の要素数
                assert(elemNum > 0);
                if (elemNum == 1) {
                    r ~= "T e" ~ toString(argCount) ~ ", ";
                } else {
                    r ~= "Vector!(T," ~ toString(elemNum) ~ ") e" ~ toString(argCount) ~ ", ";
                }
                argCount++;
                b ~= elemNum;
            }
            int elemNum = S-1 - (i == 0 ? 0 : a[$-1]); //引数の要素数
            assert(elemNum > 0);
            if (elemNum == 1) {
                r ~= "T e" ~ toString(argCount++);
            } else {
                r ~= "Vector!(T," ~ toString(elemNum) ~ ") e" ~ toString(argCount);
            }
            b ~= elemNum;
            r ~= ") {\n";
            int count = 0;
            foreach (int arg,k; b) { //k個の要素
                foreach (l; 0..k) {
                    r ~= "elements[" ~ toString(count++) ~ "] = ";
                    r ~= "e" ~ toString(arg);
                    if (k == 1) r ~= ";";
        else {
                        r ~= "[" ~ toString(l) ~ "];";
                    }
                    r ~= "\n";
                }
            }
            r ~= "}\n";
            return;
        }
        if (j == S-1) return;//後がない。終了。
        //再帰
        rec(a ~ j, j+1,i);
        rec(a, j+1,i);
    }
    foreach (i; 1..S) {
        rec([], 0, i);
    }
    return r;
}

private string getXyzwCode(const string expression, uint S) {

    const string expr = expression[0..S];
    int indexOf(string s, char c) {
        foreach (int i, ss; s) {
            if (ss == c) return i;
        }
        return -1;
    }
    string code;
    //k文字のものについて考える。xは前につくk-1文字の名前
    void func(int k, string x) {
        if (k > S) return;
        //k文字目を決める
        foreach (j; 0..S) {
            if (contains(expr[j], x)) continue;
            x = x[0..k-1] ~ expr[j];
            if (k == 1) {
                code ~= "T " ~ x ~ "() const {";
                code ~= "return elements[" ~ toString(indexOf(expr, x[0])) ~ "];";
                code ~= "} ";
                code ~= "ref T " ~ x ~ "() {";
                code ~= "return elements[" ~ toString(indexOf(expr, x[0])) ~ "];";
                code ~= "} ";
            } else {
                code ~= "Vector!(T," ~ toString(k) ~ ") " ~ x ~ "(Vector!(T," ~ toString(k) ~ ") v) {";
                foreach (l; 0..k) {
                    code ~= "elements[" ~ toString(indexOf(expr, x[l])) ~ "] = v[" ~ toString(l) ~ "];";
                }
                code ~= "return " ~ x ~ ";";
                code ~= "}";
                code ~= "Vector!(T," ~ toString(k) ~ ") " ~ x ~ "() const {";
                code ~= "return Vector!(T, " ~ toString(k) ~ ")(";
                foreach (l; 0..k) {
                    code ~= "elements[" ~ toString(indexOf(expr, x[l])) ~ "]";
                    if (l != k-1) code ~= ",";
                }
                code ~= ");} ";
            }

            func(k+1, x);
        }
    }
    func(1, "");
    return code;
}

private string getUnaryCode(string op, int S) {
    string code;
    foreach (i; 0..S) {
        code ~= "result.elements[" ~ to!string(i) ~ "] = " ~ op ~ "elements[" ~ to!string(i) ~ "];";
    }
    return code;
}
