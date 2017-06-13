module sbylib.math.Matrix;

import sbylib.math;
import std.conv;
import std.math;
import std.string;
import std.stdio;
import std.traits;
import std.format;

//T型のUxV行列
/*
   1 1 1 1
   1 1 1 1
   は
   Matrix!(float, 2, 4)
   */
struct Matrix(T, uint U, uint V) if (__traits(isArithmetic, T) && 1 <= U && U <= 4 && 1 <= V && V <= 4){
private:
    T[U*V] element;
public:

    enum dimension1 = U;
    enum dimension2 = V;
    enum type = T.stringof;

    this(T e) {
        foreach (ref el; this.element) el = e;
    }

    this(T[] elements...) in {
        assert(elements.length <= U*V);
    } body {
        foreach(i, e; elements) {
            this[i/V,i%V] = e;
        }
    }

    this(Vector!(T, U)[] vectors...) in {
        assert(vectors.length == V);
    } body {
        mixin({
            string result;
            foreach (i; 0..U) {
                foreach (j; 0..V) {
                    result ~= "this[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] = vectors[" ~ to!string(j) ~ "][" ~ to!string(i) ~ "];";
                }
            }
            return result;
        }());
    }

    Matrix opBinary(string op, S, uint P, uint Q)(const Matrix!(S, P,Q)  m) const if ((op == "+" || op == "-") && U == P && V == Q) {
        static if (isImplicitlyConvertible!(T,S)) {
            alias Type = S;
        } else {
            alias Type = T;
        }

        Matrix!(Type,U,V) result;
        mixin(getOpBinaryMMCode(op, U));
        return result;
    }

    Matrix!(S,U,Q) opBinary(string op, S, uint P, uint Q)(const Matrix!(S,P,Q) m) if (op == "*" && V == P) {
        static if (isImplicitlyConvertible!(T,S)) {
            alias Type = S;
        } else {
            alias Type = T;
        }
        Matrix!(Type,U,Q) result;
        mixin(multMMCode(U,V,P,Q));
        return result;
    }

    Matrix opBinary(string op)(T s) const {
        Matrix result;
        static if (op == "*" || op == "/") {
            mixin(getOpBinaryMSCode(op, U));
            return result;
        } else {
            static assert(false);
        }
    }

    Matrix opBinaryRight(string op)(T s) const {
        Matrix result;
        static if (op == "*" || op == "/") {
            mixin(getOpBinaryMSCode(op, U));
            return result;
        } else {
            static assert(false);
        }
    }

    Vector!(T,U) opBinary(string op)(Vector!(T,V) v) const {
        Vector!(T,U) result;
        static if (op == "*") {
            mixin(multMVCode(U, V));
            return result;
        } else {
            static assert(false);
        }
    }

    void opOpAssign(string op)(T s) {
        static if (op == "*" || op == "/") {
            mixin(getOpAssignMSCode(op, U));
        } else {
            static assert(false);
        }
    }

    void opOpAssign(string op)(Vector!(T,V) v) {
        static if (op == "*") {
            mixin(multMVAssignCode(U, V));
        } else {
            static assert(false);
        }
    }

    void opOpAssign(string op, S, uint P, uint Q)(Matrix!(S, P, Q) m) {
        static if (op == "+" || op == "-") {
            static assert(U == P && V == Q);
            mixin(getOpAssignMMCode(op, U));
        } else static if (op == "*") {
            Matrix result = this * m;
            mixin(getCopyCode("result", U, V));
        } else {
            static assert(false);
        }
    }

    Vector!(T,U)[V] column() {
        Vector!(T,U)[V] result;
        mixin(getColumnCode(U,V));
        return result;
    }

    Vector!(T,V) row(uint r) {
        mixin({
            string str;
            str ~= "Vector!(T,V) func(uint a) {";
            str ~= "Vector!(T,V) result;";
                foreach (i; 0..V) {
                    str ~= format("result[%d] = this[a,%d];", i, i);
                }
            str ~= "return result;";
            str ~= "}";
            return str;
        }());
        return func(r);
    }

    static Matrix!(T,U,V) replace(Vector!(T,U)[V] vectors...) {
        Matrix result;
        alias gen = {
            string code;
            foreach (i; 0..V) {
                foreach (j; 0..U) {
                    code ~= "result[" ~ to!string(j) ~ "," ~ to!string(i)  ~ "] = vectors[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "];";
                }
            }
            return code;
        };
        mixin(gen());
        return result;
    }

    static if (U == V) {
        static Matrix identity() {
            Matrix result;
            mixin(getidentityCode(U, V));
            return result;
        }

        static auto translate(int S)(Vector!(T, S) vec) if (U == 4 && (S == 3 || S == 4) || U == S) {
            Matrix result;
            mixin(getTranslationCode(U,V));
            return result;
        }

        static Matrix scale(int S)(Vector!(T, S) vec) if (U == 4 && (S == 3 || S == 4) || U == S) {
            Matrix result;
            mixin(getScaleCode(U,V));
            return result;
        }

    }

    static if (U == 3 && V == 3) {
        static Matrix rotAxisAngle(Vector!(T,3) v, T angle) {
            auto c = cos(angle);
            auto s = sin(angle);
            Matrix result;
            mixin(getRotAxisCode(3));
            return result;
        }

        Quaternion!T toQuaternion() {
            auto q0 = ( this[0,0] + this[1,1] + this[2,2] + 1.0f) / 4.0f;
            auto q1 = ( this[0,0] - this[1,1] - this[2,2] + 1.0f) / 4.0f;
            auto q2 = (-this[0,0] + this[1,1] - this[2,2] + 1.0f) / 4.0f;
            auto q3 = (-this[0,0] - this[1,1] + this[2,2] + 1.0f) / 4.0f;
            if(q0 < 0.0f) q0 = 0.0f;
            if(q1 < 0.0f) q1 = 0.0f;
            if(q2 < 0.0f) q2 = 0.0f;
            if(q3 < 0.0f) q3 = 0.0f;
            q0 = sqrt(q0);
            q1 = sqrt(q1);
            q2 = sqrt(q2);
            q3 = sqrt(q3);
            if(q0 >= q1 && q0 >= q2 && q0 >= q3) {
                q1 *= sgn(this[2,1] - this[1,2]);
                q2 *= sgn(this[0,2] - this[2,0]);
                q3 *= sgn(this[1,0] - this[0,1]);
            } else if(q1 >= q0 && q1 >= q2 && q1 >= q3) {
                q0 *= sgn(this[2,1] - this[1,2]);
                q2 *= sgn(this[1,0] + this[0,1]);
                q3 *= sgn(this[0,2] + this[2,0]);
            } else if(q2 >= q0 && q2 >= q1 && q2 >= q3) {
                q0 *= sgn(this[0,2] - this[2,0]);
                q1 *= sgn(this[1,0] + this[0,1]);
                q3 *= sgn(this[2,1] + this[1,2]);
            } else if(q3 >= q0 && q3 >= q1 && q3 >= q2) {
                q0 *= sgn(this[1,0] - this[0,1]);
                q1 *= sgn(this[2,0] + this[0,2]);
                q2 *= sgn(this[2,1] + this[1,2]);
            } else {
                assert(false);
            }

            auto result = Quaternion!T(q1, q2, q3, q0);
            return result.normalize;
        }

        vec3 getScale() {
            return vec3(row(0).length,
                    row(1).length,
                    row(2).length);
        }
    }

    static if (U == 4 && V == 4) {

        static Matrix rotAxisAngle(Vector!(T,3) v, T angle) {
            auto c = cos(angle);
            auto s = sin(angle);
            Matrix result;
            mixin(getRotAxisCode(4));
            return result;
        }
        static Matrix rotFromTo(Vector!(T,3) from, Vector!(T,3) to) {
            auto v = cross(from, to);
            auto s = v.length * (dot(from, to)<0 ? 1: -1);
            if (s == 0) return identity();
            auto rad = asin(v.length);
            auto c = cos(rad);
            v = normalize(v);
            Matrix result;
            mixin(getRotAxisCode(4));
            return result;
        }

        static Matrix replacement(Vector!(T,3) xvec, Vector!(T,3) yvec, Vector!(T,3) zvec) {
            Matrix result;
            mixin({
                string code;
                foreach (i; 0..3)
                    code ~= "result[" ~ to!string(i) ~ ",0] = xvec[" ~ to!string(i) ~ "];";
                foreach (i; 0..3)
                        code ~= "result[" ~ to!string(i) ~ ",1] = yvec[" ~ to!string(i) ~ "];";
                foreach (i; 0..3)
                            code ~= "result[" ~ to!string(i) ~ ",2] = zvec[" ~ to!string(i) ~ "];";
                                foreach (i; 0..3)
                                    code ~= "result[" ~ to!string(i) ~ ",3] = 0;";
                                        foreach (i; 0..3)
                                            code ~= "result[3," ~ to!string(i) ~ "] = 0;";
                                                code ~= "result[3,3] = 1;";
                                                return code;
            }());
                return result;
            }

            static Matrix lookAt(Vector!(T,3) eye, Vector!(T,3) vec, Vector!(T,3) up) {
                Matrix result;
                mixin(getLookAtCode());
                return result;
            }

            static Matrix ortho(T width, T height, T nearZ, T farZ) {
                Matrix result;
                mixin(getOrthoCode());
                return result;
            }

            static Matrix perspective(T aspectWperH, T fovy, T nearZ, T farZ) {
                Matrix result;
                mixin(getPerspectiveCode());
                return result;
            }

            Matrix!(T,3,3) toMatrix3() {
                return Matrix!(T,3,3)(element[0..3]~element[4..7]~element[8..11]);
            }

            vec3 getScale() {
                return toMatrix3.getScale;
            }

            vec3 getTranslation() {
                return vec3(this[0,3], this[1,3], this[2,3]);
            }

    }

    static Matrix invert(Matrix m) {
        static if (U == 4 && V == 4) {
            auto e2233_2332 = m[2,2] * m[3,3] - m[2,3] * m[3,2];
            auto e2133_2331 = m[2,1] * m[3,3] - m[2,3] * m[3,1];
            auto e2132_2231 = m[2,1] * m[3,2] - m[2,2] * m[3,1];
            auto e1233_1332 = m[1,2] * m[3,3] - m[1,3] * m[3,2];
            auto e1133_1331 = m[1,1] * m[3,3] - m[1,3] * m[3,1];
            auto e1132_1231 = m[1,1] * m[3,2] - m[1,2] * m[3,1];
            auto e1322_1223 = m[1,3] * m[2,2] - m[1,2] * m[2,3];
            auto e1123_1321 = m[1,1] * m[2,3] - m[1,3] * m[2,1];
            auto e1122_1221 = m[1,1] * m[2,2] - m[1,2] * m[2,1];
            auto e2033_2330 = m[2,0] * m[3,3] - m[2,3] * m[3,0];
            auto e2032_2230 = m[2,0] * m[3,2] - m[2,2] * m[3,0];
            auto e1033_1330 = m[1,0] * m[3,3] - m[1,3] * m[3,0];
            auto e1032_1230 = m[1,0] * m[3,2] - m[1,2] * m[3,0];
            auto e1023_1320 = m[1,0] * m[2,3] - m[1,3] * m[2,0];
            auto e1022_1220 = m[1,0] * m[2,2] - m[1,2] * m[2,0];
            auto e2031_2130 = m[2,0] * m[3,1] - m[2,1] * m[3,0];
            auto e1031_1130 = m[1,0] * m[3,1] - m[1,1] * m[3,0];
            auto e1021_1120 = m[1,0] * m[2,1] - m[1,1] * m[2,0];
            auto det =
                m[0,0] * (m[1,1] * e2233_2332 - m[1,2] * e2133_2331 + m[1,3] * e2132_2231) -
                m[0,1] * (m[1,0] * e2233_2332 - m[1,2] * e2033_2330 + m[1,3] * e2032_2230) +
                m[0,2] * (m[1,0] * e2133_2331 - m[1,1] * e2033_2330 + m[1,3] * e2031_2130) -
                m[0,3] * (m[1,0] * e2132_2231 - m[1,1] * e2032_2230 + m[1,2] * e2031_2130)
            ;
            if (det != 0) det = 1 / det;
            auto t00 =  m[1,1] * e2233_2332 - m[1,2] * e2133_2331 + m[1,3] * e2132_2231;
            auto t01 = -m[0,1] * e2233_2332 + m[0,2] * e2133_2331 - m[0,3] * e2132_2231;
            auto t02 =  m[0,1] * e1233_1332 - m[0,2] * e1133_1331 + m[0,3] * e1132_1231;
            auto t03 =  m[0,1] * e1322_1223 + m[0,2] * e1123_1321 - m[0,3] * e1122_1221;
            auto t10 = -m[1,0] * e2233_2332 + m[1,2] * e2033_2330 - m[1,3] * e2032_2230;
            auto t11 =  m[0,0] * e2233_2332 - m[0,2] * e2033_2330 + m[0,3] * e2032_2230;
            auto t12 = -m[0,0] * e1233_1332 + m[0,2] * e1033_1330 - m[0,3] * e1032_1230;
            auto t13 = -m[0,0] * e1322_1223 - m[0,2] * e1023_1320 + m[0,3] * e1022_1220;
            auto t20 =  m[1,0] * e2133_2331 - m[1,1] * e2033_2330 + m[1,3] * e2031_2130;
            auto t21 = -m[0,0] * e2133_2331 + m[0,1] * e2033_2330 - m[0,3] * e2031_2130;
            auto t22 =  m[0,0] * e1133_1331 - m[0,1] * e1033_1330 + m[0,3] * e1031_1130;
            auto t23 = -m[0,0] * e1123_1321 + m[0,1] * e1023_1320 - m[0,3] * e1021_1120;
            auto t30 = -m[1,0] * e2132_2231 + m[1,1] * e2032_2230 - m[1,2] * e2031_2130;
            auto t31 =  m[0,0] * e2132_2231 - m[0,1] * e2032_2230 + m[0,2] * e2031_2130;
            auto t32 = -m[0,0] * e1132_1231 + m[0,1] * e1032_1230 - m[0,2] * e1031_1130;
            auto t33 =  m[0,0] * e1122_1221 - m[0,1] * e1022_1220 + m[0,2] * e1021_1120;
            Matrix r;
            r[0,0] =  det * t00;
            r[0,1] =  det * t01;
            r[0,2] =  det * t02;
            r[0,3] =  det * t03;
            r[1,0] =  det * t10;
            r[1,1] =  det * t11;
            r[1,2] =  det * t12;
            r[1,3] =  det * t13;
            r[2,0] =  det * t20;
            r[2,1] =  det * t21;
            r[2,2] =  det * t22;
            r[2,3] =  det * t23;
            r[3,0] =  det * t30;
            r[3,1] =  det * t31;
            r[3,2] =  det * t32;
            r[3,3] =  det * t33;
            return r;
        }
        static if (U == 3 && V == 3) {
            auto det =
                 + m[0,0]*m[1,1]*m[2,2]
+ m[0,1]*m[1,2]*m[2,0]
             + m[0,2]*m[1,0]*m[2,1]
             - m[0,0]*m[1,2]*m[2,1]
             - m[0,1]*m[1,0]*m[2,2]
- m[0,2]*m[1,1]*m[2,0];
            if (det != 0) det = 1 / det;
            Matrix r;
            r[0,0] = (m[1,1]*m[2,2] - m[1,2]*m[2,1]) * det;
            r[0,1] = (m[0,2]*m[2,1] - m[0,1]*m[2,2]) * det;
            r[0,2] = (m[0,1]*m[1,2] - m[0,2]*m[1,1]) * det;
            r[1,0] = (m[1,2]*m[2,0] - m[1,0]*m[2,2]) * det;
            r[1,1] = (m[0,0]*m[2,2] - m[0,2]*m[2,0]) * det;
            r[1,2] = (m[0,2]*m[1,0] - m[0,0]*m[1,2]) * det;
            r[2,0] = (m[1,0]*m[2,1] - m[1,1]*m[2,0]) * det;
            r[2,1] = (m[0,1]*m[2,0] - m[0,0]*m[2,1]) * det;
            r[2,2] = (m[0,0]*m[1,1] - m[0,1]*m[1,0]) * det;
            return r;
        }
        static if (U == 2 && V == 2) {
            auto det = m[0,0]*m[1,1] - m[0,1]*m[1,0];
            if (det != 0) det = 1 / det;
            Matrix r;
            r[0,0] = +m[1,1] * det;
            r[0,1] = -m[0,1] * det;
            r[1,0] = -m[1,0] * det;
            r[1,1] = +m[0,0] * det;
            return r;
        }
        assert(false);
    }

    static if (V == U) {
        //static Matrix!(T, U, V) diagnalizate(Matrix m) {
        static Matrix!(T, U, V) diagonalize(Matrix m) {
            // すべて実数固有値で全部相違であると仮定しています
            // ＞ めっちゃ条件付き ＜

            // hessenberg
            Matrix!(T,U,V) H;
            for(int i=0;i<U;++i)for(int j=0;j<V;++j)
                    H[i,j] = m[i,j];
            H.writeln;
            for(int k=1;k<=U-2;++k){
                T[U] u;
                u[] = 0;
                for(int i=k;i<U;++i)
                    u[i] = H[i,k-1];
                T ss = 0.0;
                for(int i=k+1;i<U;++i)
                    ss += u[i]*u[i];
                if(abs(ss)<=0.0) continue;
                T s = sqrt(ss+u[k]*u[k]);
                if(u[k]>0.0) s = -s;
                u[k] -= s;
                T uu = sqrt(ss+u[k]*u[k]);
                for(int i=k;i<U;++i)
                    u[i] /= uu;
                T[U] f,g;
                f[] = 0;
                g[] = 0;
                for(int i=0;i<U;++i)
                    for(int j=k;j<U;++j){
                        f[i] += H[i,j]*u[j];
                        g[i] += H[j,i]*u[j];
                    }
                T gamma = 0.0;
                for(int i=0;i<U;++i)
                    gamma += u[i]*g[i];
                for(int i=0;i<U;++i)
                    f[i] -= gamma*u[i], g[i] -= gamma*u[i];
                for(int i=0;i<U;++i)
                    for(int j=0;j<U;++j)
                        H[i,j] -= 2.0*u[i]*g[j] + 2.0*f[i]*u[j];
            }
            // QR method
            T[U] sn,cs;
            const T EPS = 1e-12;
            for(int n=U;n>=2;){
                if(abs(H[n-1,n-2])<EPS){
                    --n; continue;
                }
                T shift = H[n-1,n-1];
                for(int i=0;i<n;++i)
                    H[i,i] -= shift;
                for(int k=0;k<n-1;++k){
                    T a = H[k,k];
                    T b = H[k+1,k];
                    T r = sqrt(a*a+b*b);
                    sn[k] = (r==0.0 ? 0.0 : b/r);
                    cs[k] = (r==0.0 ? 0.0 : a/r);
                    for(int j=k;j<n;++j){
                        T x = H[k,j], y = H[k+1,j];
                        H[k,j] = cs[k]*x + sn[k]*y;
                        H[k+1,j] = -sn[k]*x + cs[k]*y;
                    }
                }
                for(int k=0;k<n-1;++k){
                    for(int i=0;i<=k+1;++i){
                        T x = H[i,k], y = H[i,k+1];
                        H[i,k] = cs[k]*x + sn[k]*y;
                        H[i,k+1] = -sn[k]*x + cs[k]*y;
                    }
                }
                for(int i=0;i<n;++i)
                    H[i,i] += shift;
            }
            T[U] lambda;
            for(int i=0;i<U;++i)
                lambda[i]=H[i,i];
            lambda.writeln;
            // 未完
            // TODO: 同じ固有値の検出、連立方程式の求解
            return identity;
        }
        // こっち使って :sobaya:
        static Matrix!(T,U,V) diagonalizeForRealSym(Matrix m){
            auto result = identity;

            T getMaxValue(ref Matrix m, out uint p, out uint q) {
                T max = 0;
                foreach (i; 0..U) {
                    foreach (j; 0..V) {
                        if (i == j) continue;
                        if (m[i,j].abs > max) {
                            max = m[i,j].abs;
                            p = i;
                            q = j;
                        }
                    }
                }
                return max;
            }
            T max;
            uint p, q;
            while (true) {
                if ((max = getMaxValue(m, p, q)) < 1e-3) break;
                T pp = m[p,p];
                T pq = m[p,q];
                T qq = m[q,q];
                T alpha = (pp - qq) / 2.0;
                T beta = -pq;
                T gamma = abs(alpha) / sqrt(alpha*alpha+beta*beta);
                T s = sqrt((1.0-gamma) / 2.0);
                T c = sqrt((1.0+gamma) / 2.0);
                if (alpha * beta < 0) s = -s;
                foreach (i; 0..U) {
                    T tmp = c * m[p, i] - s * m[q, i];
                    m[q, i] = s * m[p, i] + c * m[q, i];
                    m[p, i] = tmp;
                }
                foreach (i; 0..U) {
                    m[i,p] = m[p,i];
                    m[i,q] = m[q,i];
                }
                m[p,p] = c*c*pp + s*s*qq - 2*s*c*pq;
                m[p,q] = s*c*(pp-qq) + (c*c-s*s) * pq;
                m[q,p] = m[p,q];
                m[q,q] = s*s*pp + c*c*qq + 2*s*c*pq;
                foreach (i; 0..U) {
                    T tmp = c*result[i,p]-s*result[i,q];
                    result[i,q] = s*result[i,p] + c*result[i,q];
                    result[i,p] = tmp;
                }
            }
            return result;
        }
    }

    static Matrix!(T,V,U) transpose(Matrix m) {

        mixin({
            string result = "Matrix!(T,V,U) r;";
            foreach (i;0..V) {
                foreach (j;0..U) {
                    result ~= "r[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] = ";
                        result ~= "m[" ~ to!string(j) ~ "," ~ to!string(i) ~ "];";
                }
            }
            result ~= "return r;";
            return result;
        }());
    }

    string toString(T epsilon = 0) inout {
        string res;
        foreach (i; 0..U) {
            res ~= "\n\t";
            foreach (j; 0..V) {
                res ~= format!"%10f,"(this[i,j]);
            }
        }
        return res;
    }

    T opIndex(size_t i, size_t j) inout { //i = tate, y = yoko
        return element[j+i*V];
    }

    T opIndexAssign(T value, size_t i, size_t j) {
        return element[j+i*V] = value;
    }

    T opIndexOpAssign(string op)(T value, size_t x, size_t y) {
        mixin("return element[y*V+x] " ~ op ~ "= value;");
    }

    T[U*V] array() inout {
        return element;
    }
}

alias Matrix!(float, 2, 2) mat2;
alias Matrix!(double, 2, 2) mat2d;
alias Matrix!(float, 3, 3) mat3;
alias Matrix!(double, 3, 3) mat3d;
alias Matrix!(float, 4, 4) mat4;
alias Matrix!(double, 4, 4) mat4d;


//============================================================================以下mixin用の関数達

private static string multMMCode(uint U, uint V, uint P, uint Q) {
    string code;
    foreach (i; 0..U) {
        foreach (j; 0..V) {
            code ~= format!"result[%d,%d] = "(i,j);
            foreach (k; 0..V) {
                code ~= format!"+ this[%d,%d] * m[%d,%d]"(i,k,k,j);
            }
            code ~= ";";
        }
    }
    return code;
}

private static string multMVCode(uint U, uint V) {
    string code;
    foreach (i; 0..U) {
        code ~= format!"result[%d] = "(i);
        foreach (j; 0..V) {
            code ~= format!"+this[%d, %d] * v[%d]"(i,j,j);
        }
        code ~= ";";
    }
    return code;
}

private static string multMVAssignCode(uint U, uint V) {
    string code;
    foreach (i; 0..U) {
        code ~= "this[" ~ to!string(i) ~ "] = ";
        foreach (j; 0..V) {
            code ~= "+ this[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] * v[" ~ to!string(j) ~ "]";
        }
        code ~= ";";
    }
    return code;
}

private static string getidentityCode(uint U, uint V) {
    string code;
    foreach (i; 0..U) {
        foreach (j; 0..V) {
            code ~= "result[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] = ";
            if (i == j) code ~= "1;";
            else code ~= "0;";
        }
    }
    return code;
}

private static string getTranslationCode(uint U, uint V) {
    string code;
    foreach (i; 0..U) {
        foreach (j; 0..V) {
            code ~= format!"result[%d,%d] = "(i,j);
            if (i == j) code ~= "1;";
            else if (j == V-1) code ~= format!"vec[%d];"(i);
            else code ~= "0;";
        }
    }
    return code;
}

private static string getScaleCode(uint U, uint V) {
    string code;
    foreach (i; 0..U) {
        foreach (j; 0..V) {
            code ~= "result[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] = ";
            if (U == 4 && V == 4 && i == 3 && j == 3) code ~= "1;";
            else if (i == j) code ~= "vec[" ~ to!string(i) ~ "];";
            else code ~= "0;";
        }
    }
    return code;
}

private static string getRotAxisCode(uint U) {
    string code;
    foreach (i; 0..U) {
        foreach (j; 0..U) {
            code ~= "result[" ~ to!string(i) ~ "," ~ to!string(j) ~ "] = ";
            if (i == 3 && j == 3)
                code ~= "1;";
            else if (i == 3 || j == 3)
                code ~= "0;";
            else if (i == j)
                code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)+c;";
            else if (j == (i+1)%3)
                code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)+v[" ~ to!string((i+2)%3) ~ "]*s;";
            else
                code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)-v[" ~ to!string((i+1)%3) ~ "]*s;";
        }
    }
    return code;
}

private static string getOpBinaryMMCode(string op, uint U) {
    string code;
    foreach (i; 0..U) {
        code ~= "result[" ~ to!string(i) ~ ",] = this[" ~ to!string(i) ~ ",]" ~ op ~ "m[" ~ to!string(i) ~ ",];";
    }
    return code;
}

private static string getOpBinaryMSCode(string op, uint U) {
    string code;
    foreach (i; 0..U) {
        code ~= "result[" ~ to!string(i) ~ ",] = this[" ~ to!string(i) ~ ",]" ~ op ~ "s;";
    }
    return code;
}

private static string getOpAssignMSCode(string op, uint U) {
    string code;
    foreach (i; 0..U) {
        code ~= "this[" ~ to!string(i) ~ ",] " ~ op ~ "= s;";
    }
    return code;
}

private static string getOpAssignMMCode(string op, uint U) {
    string code;
    foreach (i; 0..U) {
        code ~= "this[" ~ to!string(i) ~ ",] " ~ op ~ "= m[" ~ to!string(i) ~ ",];";
    }
    return code;
}

private static string getLookAtCode() {
    string code;
    code ~= "Vector!(T,3) side;";
    //sideを外積で生成
    foreach (i; 0..3) {
        code ~= format!"side[%d] = up[%d] * vec[%d] - up[%d] * vec[%d];"(i, (i+1)%3, (i+2)%3, (i+2)%3, (i+1)%3);
    }
    //sideを正規化
    code ~= "T length = sqrt(";
    foreach (i; 0..3) {
        code ~= format!"+side[%d]*side[%d]"(i,i);
    }
    code ~= ");";
    foreach (i; 0..3) {
        code ~= format!"side[%d] /= length;"(i);
    }
    //upを再計算
    foreach (i; 0..3) {
        code ~= format!"up[%d] = vec[%d] * side[%d] - vec[%d] * side[%d];"(i,(i+1)%3,(i+2)%3,(i+2)%3,(i+1)%3);
    }
    //upを正規化
    code ~= "length = sqrt(";
    foreach (i; 0..3) {
        code ~= format!"+up[%d] * up[%d]"(i,i);
    }
    code ~= ");";
    foreach (i; 0..3) {
        code ~= format!"up[%d] /= length;"(i);
    }

    //行列
    foreach (i; 0..3) {
        code ~= format!"result[0,%d] = side[%d];"(i,i);
        code ~= format!"result[1,%d] = up[%d];"(i,i);
        code ~= format!"result[2,%d] = vec[%d];"(i,i);
    }
    foreach (i; 0..3) {
        code ~= format!"result[%d,3] = "(i);
        foreach (j; 0..3) {
            code ~= format!"-eye[%d] * result[%d, %d]"(j, j, i);
        }
        code ~= ";";
    }
    foreach (i; 0..3) {
        code ~= format!"result[3, %d] = 0;"(i);
    }
    code ~= "result[3,3] = 1;";
    return code;
}

private static string getOrthoCode() {
    string code;
    foreach (i; 0..4) {
        if (i != 0) code ~= "result[0," ~ to!string(i) ~ "] = 0;";
    }
    foreach (i; 0..4) {
        if (i != 1) code ~= "result[1," ~ to!string(i) ~ "] = 0;";
    }
    foreach (i; 0..4) {
        if (i < 2) code ~= "result[2," ~ to!string(i) ~ "] = 0;";
    }
    foreach (i; 0..3) {
        code ~= "result[3," ~ to!string(i) ~ "] = 0;";
    }
    code ~= "result[0,0] = 2 / width;";
    code ~= "result[1,1] = 2 / height;";
    code ~= "result[2,2] = 1 / (farZ - nearZ);";
    code ~= "result[2,3] = nearZ / (nearZ - farZ);";
    code ~= "result[3,3] = 1;";
    return code;
}

private static string getPerspectiveCode() {
    string code;
    foreach (i; 0..4) {
        if (i != 0) code ~= format!"result[0,%d] = 0;"(i);
    }
    foreach (i; 0..4) {
        if (i != 1) code ~= format!"result[1,%d] = 0;"(i);
    }
    foreach (i; 0..2) {
        code ~= format!"result[2,%d] = 0;"(i);
    }
    foreach (i; 0..4) {
        if (i != 2) code ~= format!"result[3,%d] = 0;"(i);
    }
    code ~= "result[0,0] = 1 / (aspectWperH * tan(fovy/2));";
    code ~= "result[1,1] = 1 / (tan(fovy/2));";
    code ~= "result[2,2] = (nearZ+farZ)/(nearZ-farZ);";
    code ~= "result[2,3] = 2 * nearZ * farZ / (nearZ - farZ);";
    code ~= "result[3,2] = -1;";
    return code;
}

private static string getStringCode(uint U, uint V) {
    string code = "T a;\n";
    code ~= "string r;\n";
    foreach (y; 0..U) {
        foreach (x; 0..V) {
            code ~= "a = this[" ~ to!string(y) ~ "," ~ to!string(x) ~ "];\n";
            code ~= "if (abs(a) < epsilon) a = 0;\n";
            code ~= "r ~= to!string(a);\n";
            if (x < V-1) code ~= "r ~= \",\";\n";
        }
        if (y < U-1) code ~= "r ~= \"\\n\";\n";
    }
    code ~= "return r;\n";
    return code;
}

private static string getCopyCode(string identifier, uint U, uint V) {
    string code;
    foreach (x; 0..U) {
        foreach (y; 0..V) {
            code ~= "this[" ~ to!string(x) ~ "," ~ to!string(y) ~ "]
            = " ~ identifier ~ "[" ~ to!string(x) ~ "," ~ to!string(y) ~ "];";
        }
    }
    return code;
}

private static string getColumnCode(uint U, uint V) {
    string code;
    foreach (j; 0..V) {
        foreach (i; 0..U) {
            code ~= format!"result[%d][%d] = this[%d, %d];"(j, i, i, j);
        }
    }
    return code;
}

unittest {
    import std.stdio;
    auto p = vec4(0,1,2,1);
    auto m = mat4(
            1,0,0,100,
            0,1,0,200,
            0,0,1,300,
            0,0,0,1);
    assert(m * p == vec4(100,201,302,1));
    auto t = mat4.translate(vec3(100,200,300));
    assert(m == t);
}
