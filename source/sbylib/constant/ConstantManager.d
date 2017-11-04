module sbylib.constant.ConstantManager;

import std.file;
import std.json;
import std.algorithm;
import std.array;
import sbylib.setting;
import sbylib.constant.Const;
import sbylib.math.Vector;

class ConstantManager {

    enum PATH = RESOURCE_ROOT ~ "const.json";

    static Const[string] consts;

    static void init() {
        if (!exists(PATH)) {
            JSONValue value = parseJSON("{}");
            write(PATH, value.toString());
        }
        reload();
    }

    static void update() {
        JSONValue root;
        foreach (key, value; this.consts) {
            root[key] = value.getJSON();
        }
        write(PATH, root.toString());
    }

    static void reload() {
        JSONValue root = parseJSON(readText(PATH));
        foreach (string key, value; root) {
            if (key in consts) {
                consts[key].setValue(conv(key, value));
            } else {
                consts[key] = conv(key, value);
            }
        }
    }
    private static Const conv(string name, JSONValue value) {
        switch (value.type) {
        case JSON_TYPE.ARRAY:
            auto array = value.array();
            return convArray(name, array);
        case JSON_TYPE.FLOAT:
            return new ConstTemp!float(name, value.floating());
        case JSON_TYPE.INTEGER:
            return new ConstTemp!float(name, cast(int)value.integer());
        case JSON_TYPE.UINTEGER:
            return new ConstTemp!float(name, cast(int)value.uinteger());
        case JSON_TYPE.STRING:
            return new ConstTemp!string(name, value.str());
        default:
            assert(false);
        }
    }

    private static Const convArray(string name, JSONValue[] value) {
        switch (value[0].type) {
        case JSON_TYPE.FLOAT:
            return convFloatArray(name, value);
        case JSON_TYPE.INTEGER:
        case JSON_TYPE.UINTEGER:
            return convArrayTyped!int(name, value);
        case JSON_TYPE.TRUE:
        case JSON_TYPE.FALSE:
            return convArrayTyped!bool(name, value);
        default:
            assert(false);
        }
    }

    private static Const convArrayTyped(T)(string name, JSONValue[] value) {
        static if (is(T == int)) {
            alias conv = (j) {
                if (j.type == JSON_TYPE.INTEGER) return cast(int)j.integer();
                else if (j.type == JSON_TYPE.UINTEGER) return cast(int)j.uinteger();
                else assert(false);
            };
        } else static if (is(T == string)) {
            alias conv = j => j.str();
        } else static if (is(T == bool)) {
            alias conv = (j) {
                if (j.type == JSON_TYPE.TRUE) return true;
                else if (j.type == JSON_TYPE.FALSE) return false;
                else assert(false);
            };
        }
        return new ConstTemp!(T[])(name, value.map!conv.array);
    }

    private static Const convFloatArray(string name, JSONValue[] value) {
        switch (value.length) {
        case 1:
            return new ConstTemp!float(name, value[0].floating());
        case 2:
            return new ConstTemp!vec2(name, vec2(value[0].floating(), value[1].floating()));
        case 3:
            return new ConstTemp!vec3(name, vec3(value[0].floating(), value[1].floating(), value[2].floating()));
        case 4:
            return new ConstTemp!vec4(name, vec4(value[0].floating(), value[1].floating(), value[2].floating(), value[3].floating()));
        default:
            assert(false);
        }
    }

    static ConstTemp!T add(T)(string name, T value) {
        auto res = new ConstTemp!T(name, value);
        consts[name] = res;
        return res;
    }

    static ConstTemp!T get(T)(string name) {
        import std.format;
        assert(name in consts, format!"%s is not found"(name));
        auto po = consts[name];
        assert(po, format!"%s is not found."(name));
        auto res = cast(ConstTemp!T)po;
        assert(res, format!"%s is not %s"(name, T.stringof));
        return res;
    }
}
