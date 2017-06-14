module sbylib.math.Quaternion;


import sbylib.math.Vector;
import sbylib.math.Matrix;
import std.math;
import std.conv;
/*Note:
  四元数の構造体だよ！
  四元数はx,y,z,wの４要素で(w; (x,y,z))と表わされるよ！
  三次元のベクトル(x,y,z)を四元数で表すときは(0; (x,y,z))とするよ！(w = 0とするってことだよ！)
  四元数の性質として、三次元ベクトルを原点を通る任意の軸周りに回転させることができるよ！
  例えば三次元ベクトルvを原点を通る軸aの周りにθ回転させるときは次のようにするんだ！
  q = (cos(θ/2); sin(θ/2) a)
  として、開店後のベクトルv'は
  v' = ( q * v * q' )の(x,y,z)
  で計算できるよ！ただし
  q' = (cos(θ/2); -sin(θ/2) a)
  だよ！
 */

struct Quaternion(T) if (__traits(isArithmetic, T)) {

    T x, y, z, w;

    this(T x, T y, T z, T w) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    this(Vector!(T,3) v, T w) {
        this(v.x,v.y,v.z,w);
    }

    //from marupeke296.com
    deprecated this(Matrix!(T, 3, 3) m) {
        auto elem = [
         +m[0,0] - m[1,1] - m[2,2] + 1,
        -m[0,0] + m[1,1] - m[2,2] + 1,
        -m[0,0] - m[1,1] + m[2,2] + 1,
        +m[0,0] + m[1,1] + m[2,2] + 1,
        ];

        uint biggestIndex = 0;
        foreach (i; 1..4) {
            if (elem[i] > elem[biggestIndex]) {
                biggestIndex = i;
            }
        }
        assert(elem[biggestIndex] >= 0);

        auto v = sqrt(elem[biggestIndex]) / 2;
        auto q = new T[4];
        q[biggestIndex] = v;
        float mult = 0.25f / v;
        final switch (biggestIndex) {
        case 0:
            q[1] = (m[0,1] + m[1,0]) * mult;
            q[2] = (m[0,2] + m[2,0]) * mult;
            q[3] = (m[2,1] - m[1,2]) * mult;
            break;
        case 1:
            q[0] = (m[0,1] + m[1,0]) * mult;
            q[2] = (m[1,2] + m[2,1]) * mult;
            q[3] = (m[0,2] - m[2,0]) * mult;
            break;
        case 2:
            q[0] = (m[0,2] + m[2,0]) * mult;
            q[1] = (m[1,2] + m[2,1]) * mult;
            q[3] = (m[1,0] - m[0,1]) * mult;
            break;
        case 3:
            q[0] = (m[2,1] - m[1,2]) * mult;
            q[1] = (m[0,2] - m[2,0]) * mult;
            q[2] = (m[0,1] - m[1,0]) * mult;
            break;
        }
        this.x = q[0];
        this.y = q[1];
        this.z = q[2];
        this.w = q[3];
    }

    inout {
        vec3 baseX() {
            return vec3(1-2*(y*y+z*z),
                    2*(x*y+w*z),
                    2*(x*z-w*y));
        }

        vec3 baseY() {
            return vec3(2*(x*y-z*w),
                    1-2*(x*x+z*z),
                    2*(y*z+w*x));
        }

        vec3 baseZ() {
            return vec3(2*(x*z+w*y),
                    2*(y*z-w*x),
                    1-2*(x*x+y*y));
        }
    }

    const(mat3) toMatrix3() const {
        return mat3(1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+w*y),
                2*(x*y+w*z), 1-2*(x*x+z*z), 2*(y*z-w*x),
                2*(x*z-w*y), 2*(y*z+w*x), 1-2*(x*x+y*y)
                );
    }

    mat4 toMatrix4() const {
        return mat4(1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+w*y), 0,
                2*(x*y+w*z), 1-2*(x*x+z*z), 2*(y*z-w*x), 0,
                2*(x*z-w*y), 2*(y*z+w*x), 1-2*(x*x+y*y), 0,
                0, 0, 0, 1
                );
    }

    Quaternion!T opUnary(string op)() const {
        static if (op == "+") {
            return this;
        } else static if (op == "-") {
            return Quaternion!T(-x,-y,-z,-w);
        } else static if (op == "~") {
            return Quaternion!T(-x,-y,-z,+w);
        } else {
            static assert(false);
        }
    }

    ref T opIndex(uint i) {
        switch (i) {
        case 0: return x;
        case 1: return y;
        case 2: return z;
        case 3: return w;
        default: assert(false);
        }
    }

    Quaternion!T opBinary(string op)(Quaternion!T q) const {
        Quaternion!T result;
        static if (op == "+" || op == "-") {
            mixin({
                return "
          result.x = x " ~ op ~ " q.x;
          result.y = y " ~ op ~ " q.y;
          result.z = z " ~ op ~ " q.z;
          result.w = w " ~ op ~ " q.w;
          return result;
          ";
            }());
        } else static if (op == "*") {
            result.w = w * q.w - x * q.x - y * q.y - z * q.z;
            result.x = w * q.x + x * q.w + y * q.z - z * q.y;
            result.y = w * q.y - x * q.z + y * q.w + z * q.x;
            result.z = w * q.z + x * q.y - y * q.x + z * q.w;
            return result;
        }
    }

    Quaternion!T opBinary(string op)(T t) {
        static if (op == "+" || op == "-" || op == "*" || op == "/") {
            Quaternion!T result;
            mixin({
                return "
          result.x = x " ~ op ~ " t;
          result.y = y " ~ op ~ " t;
          result.z = z " ~ op ~ " t;
          result.w = w " ~ op ~ " t;
          return result;
          ";
            }());
        } else {
            static assert(false);
        }
    }

    void opOpAssign(string op)(Quaternion!T q) {
        static if (op == "+" || op == "-") {
            mixin({
                return "
          this.x = x " ~ op ~ " q.x;
          this.y = y " ~ op ~ " q.y;
          this.z = z " ~ op ~ " q.z;
          this.w = w " ~ op ~ " q.w;";
            }());
        } else static if (op == "*") {
            Quaternion result;
            result.w = w * q.w - x * q.x - y * q.y - z * q.z;
            result.x = w * q.x + x * q.w + y * q.z - z * q.y;
            result.y = w * q.y - x * q.z + y * q.w + z * q.x;
            result.z = w * q.z + x * q.y - y * q.x + z * q.w;
            this.x = result.x;
            this.y = result.y;
            this.z = result.z;
            this.w = result.w;
        } else {
            static assert(false);
        }
    }

    void opOpAssign(string op)(T t) {
        static if (op == "+" || op == "-" || op == "*" || op == "/") {
            mixin({
                return "
          this.x = x " ~ op ~ " t;
          this.y = y " ~ op ~ " t;
          this.z = z " ~ op ~ " t;
          this.w = w " ~ op ~ " t;
          ";
            }());
        } else {
            static assert(false);
        }
    }

    string toString() const {
        import std.format;
        return format!"q(%s, %s, %s, %s)"(this.x, this.y, this.z, this.w);
    }

    @property {
        Vector!(T,3) Axis() {
            return Vector!(T,3)(x,y,z);
        }

        void Axis(Vector!(T,3) axis) {
            this.x = axis.x;
            this.y = axis.y;
            this.z = axis.z;
        }
    }

    static Quaternion!T createAxisAngle(Vector!(T,3) axis, T angle) @nogc {
        Quaternion!T result;
        float s = sin(angle/2);
        result.x = axis.x * s;
        result.y = axis.y * s;
        result.z = axis.z * s;
        result.w = cos(angle/2);
        return result;
    }

    static Quaternion!T createAxisAngle(Vector!(T,3) axisAngle) @nogc {
        T angle = sbylib.math.Vector.length(axisAngle);
        if (angle == 0) return Quaternion!T(0,0,0,1);
        return createAxisAngle(axisAngle / angle, angle);
    }

    static Quaternion!T rotFromTo(Vector!(T,3) from, Vector!(T,3) to) {
        auto c = dot(from, to);
        auto v = sbylib.math.Vector.normalize(cross(from, to));
        if (v.hasNaN) {
            if (dot(from, to) > 0)
                //0度回転
                return Quaternion!T(0,0,0,1);
        else {
                //180度回転
                Vector!(T,3) axis;
                if (from.x == 0 && from.y == 0) {
                    axis = Vector!(T,3)(1,0,0);
                } else {
                    axis = sbylib.math.Vector.normalize(cross(from, Vector!(T,3)(0,0,1)));
                }
                return Quaternion!T(axis.x,axis.y,axis.z,0);
            }
        }
        return createAxisAngle(v, c.acos);
    }
}

T length(T)(Quaternion!T q) {
    mixin({
        string code = "T result = sqrt(";
        foreach (i; 0..4) {
            code ~= "+q[" ~ to!string(i) ~ "] * q[" ~ to!string(i) ~ "]";
        }
            code ~= ");";
            return code;
    }());
    return result;
}

Quaternion!T normalize(T)(Quaternion!T q) {
    return q / length(q);
}


vec3 rotate(vec3 vec, vec3 axis, float angle) @nogc {
    quat q = quat.createAxisAngle(axis, angle);
    return rotate(vec, q);
}

vec3 rotate(vec3 vec, vec3 center, vec3 axis, float angle) @nogc {
    return rotate(vec-center, axis, angle) + center;
}

vec3 rotate(vec3 vec, const quat q) @nogc {
    return (q * quat(vec, 0) * ~q).Axis;
}

alias Quaternion!float quat;

unittest {
    //つまりこう使う
    vec3 v = vec3(1,0,0);
    vec3 axis = vec3(0,1,0);
    float angle = PI / 2;
    v = rotate(v, axis, angle);
    import std.stdio;
    writeln(v.x);
    writeln(v.y);
    writeln(v.z);
    assert(vec3(0,0,-1) == vec3(0,0,-1));
    assert(v == vec3(0,0,-1));
}

