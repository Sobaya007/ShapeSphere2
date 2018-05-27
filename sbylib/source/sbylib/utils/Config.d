module sbylib.utils.Config;

import std.json;
import std.traits;

class ConfigManager {

    import std.signals;

    mixin Signal;
    mixin Signal!(string, string, JSONValue);

    private static ConfigManager instance;

    public static ConfigManager opCall() {
        if (instance is null) instance = new ConfigManager;
        return instance;
    }

    private ConfigFile[] files;

    void load() {
        emit();
    }

    private void setValue(string path, string name, JSONValue val) {
        emit(path, name, val);
    }

    ConfigFile getFile(string path) {
        import std.algorithm : find;
        import std.array;
        auto findResult = this.files.find!(file => file.path == path);
        if (!findResult.empty) return findResult.front;
        auto newFile = new ConfigFile(path);
        this.files ~= newFile;
        return newFile;
    }
}

private class ConfigFile {

    private string path;

    private this(string path) {
        this.path = path;
        this.connect(&ConfigManager().setValue);
        ConfigManager().connect(&this.load);
    }

    void load() {
        import std.file;
        auto jsonData = parseJSON(readText(path));
        foreach (string key, value; jsonData) {
            emit(path, key, value);
        }
    }

    import std.signals;
    mixin Signal!(string, string, JSONValue);
}

static auto conv(T)(string name, JSONValue value) {
    switch (value.type) {
        case JSON_TYPE.STRING:
            static if (isAssignable!(T, string)) {
                return value.str();
            } else {
                break;
            }
        case JSON_TYPE.ARRAY:
            static if (isArray!(T) && !isAssignable!(T, string)) {
                import std.algorithm : map;
                import std.array;
                auto ar = value.array().map!(v => conv!(ForeachType!(T))(name, v)).array;
                static if (isStaticArray!(T)) {
                    import std.format;
                    assert(T.length == ar.length, format!"Expected length is '%d', but %s's length is '%d'."(T.length, name, ar.length));
                    T res = ar;
                    return res;
                } else {
                    return ar;
                }
            } else {
                break;
            }
        case JSON_TYPE.FLOAT:
            static if (isAssignable!(T, double) && !isArray!(T)) {
                return cast(float)value.floating();
            } else {
                break;
            }
        case JSON_TYPE.INTEGER:
            static if (isAssignable!(T, int) && !isArray!(T)) {
                return cast(int)value.integer();
            } else {
                break;
            }
        case JSON_TYPE.UINTEGER:
            static if (isAssignable!(T, uint) && !isArray!(T)) {
                return cast(uint)value.uinteger();
            } else {
                break;
            }
        case JSON_TYPE.TRUE:
            static if (isAssignable!(T, bool) && !isArray!(T)) {
                return true;
            } else {
                break;
            }
        case JSON_TYPE.FALSE:
            static if (isAssignable!(T, bool) && !isArray!(T)) {
                return false;
            } else {
                break;
            }
        default:
            import std.format;
            assert(false, format!"Type '%s' is not allowed."(value.type));
    }
    import std.format;
    assert(false, format!"Expected Type is '%s', but %s's type is '%s'."(T.stringof, name, value.type));
}

static struct config {
    string filePath;
}

mixin template HandleConfig() {
    import std.json;
    private void initializeConfig() {
        import std.traits, std.meta;
        alias symbols = AliasSeq!(getSymbolsByUDA!(typeof(this), config));
        static assert(symbols.length > 0);
        static foreach (i; 0..symbols.length) {{
            import std.string : replace;
            enum SymbolName = symbols[i].stringof.replace("this.", "");
            alias SymbolType = typeof(symbols[i]);
            enum FilePath = getUDAs!(symbols[i], config)[0].filePath;

            ConfigManager().connect(&this.setValue!(FilePath, SymbolName, SymbolType));
            ConfigManager().getFile(FilePath).load();
        }}
    }

    private void setValue(string FilePath, string SymbolName, SymbolType)(string path, string name, JSONValue value) {
        import std.stdio;
        if (FilePath != path) return;
        if (SymbolName != name) return;

        mixin("this." ~ SymbolName) = conv!(SymbolType)(name, value);
    }
}
