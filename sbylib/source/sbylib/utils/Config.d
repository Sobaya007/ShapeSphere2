module sbylib.utils.Config;

import std.json;
import sbylib.utils.Path;
import std.traits;

class ConfigManager {

    import std.signals;
    import sbylib.utils.Functions;

    mixin Signal;
    mixin Signal!(ConfigPath, string, JSONValue);
    mixin Singleton;

    private ConfigFile[] files;

    void load() {
        emit();
    }

    private void setValue(ConfigPath path, string name, JSONValue val) {
        emit(path, name, val);
    }

    private ConfigFile getFile(ConfigPath path) {
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

    private ConfigPath path;

    private this(ConfigPath path) {
        this.path = path;
        this.connect(&ConfigManager().setValue);
        ConfigManager().connect(&this.load);
    }

    private void load() {
        import std.file;
        auto jsonData = parseJSON(readText(path));
        foreach (string key, value; jsonData) {
            emit(path, key, value);
        }
    }

    import std.signals;
    mixin Signal!(ConfigPath, string, JSONValue);
}

class ConfigValue(Type) if (isBasicType!(Type) || isArray!(Type) && isBasicType!(ForeachType!Type)) {
    private {
        bool initialized;
        Type value;
        ConfigPath path;
        string name;
    }

    this(ConfigPath path, string name) {
        this.path = path;
        this.name = name;
    }

    void initialize() {
        ConfigManager().connect(&this.setValue);
        ConfigManager().getFile(path).load();
    }

    private void setValue(ConfigPath path, string name, JSONValue value) {
        if (this.path != path) return;
        if (this.name != name) return;
        this.value = conv(name, value);
        this.initialized = true;
    }

    static T conv(T=Type)(string name, JSONValue value) {
        switch (value.type) {
            case JSON_TYPE.FLOAT:
                static if (isFloatingPoint!(T)) {
                    return value.floating();
                } else {
                    break;
                }
            case JSON_TYPE.INTEGER:
                static if (isNumeric!(T)) {
                    return cast(T)value.integer();
                } else {
                    break;
                }
            case JSON_TYPE.UINTEGER:
                static if (isNumeric!(T)) {
                    return cast(T)value.uinteger();
                } else {
                    break;
                }
            case JSON_TYPE.STRING:
                static if (isSomeString!(T)) {
                    return value.str();
                } else {
                    break;
                }
            case JSON_TYPE.TRUE:
                static if (is(T == bool)) {
                    return true;
                } else {
                    break;
                }
            case JSON_TYPE.FALSE:
                static if (is(T == bool)) {
                    return false;
                } else {
                    break;
                }
            case JSON_TYPE.ARRAY:
                static if (isArray!(T)) {
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
            default:
                import std.format;
                assert(false, format!"Type '%s' is not allowed."(value.type));
        }
                import std.format;
        assert(false, format!"Expected Type is '%s', but %s's type is '%s'."(T.stringof, name, value.type));
    }

    auto ref getValue() {
        if (!initialized) {
            this.initialize();
        }
        assert(initialized, name ~ " was not found in " ~ path);
        return this.value;
    }

    static if (isBasicType!Type) {
        import std.typecons;
        mixin Proxy!(getValue);
    }

    override string toString() {
        import std.conv : to;
        return this.getValue().to!string;
    }

    alias getValue this;
}

mixin template DeclareConfig(Type, string name, string path) {
    import std.format;
    import sbylib.utils.Path;
    enum TypeString = format!"ConfigValue!(%s)"(Type.stringof);
    mixin(format!`%s %s = new %s(ConfigPath("%s"), "%s");`(TypeString, name, TypeString, path, name));
}

mixin template DeclareConfig(Type, Type2, string name, string path) {
    import std.format;
    import sbylib.utils.Path;
    enum TypeString = format!"ConfigValue!(%s)"(Type2.stringof);
    mixin(format!`%s %s = new %s(ConfigPath("%s"), "%s");`(Type.stringof, name, TypeString, path, name));
}

static struct config {
    string filePath;
}

mixin template HandleConfig() {
    import std.json;
    private void initializeConfig() {
        import std.traits, std.meta;
        alias symbols = AliasSeq!(getSymbolsByUDA!(typeof(this), config));
        static foreach (i; 0..symbols.length) {{
            import std.string : replace;
            enum SymbolName = symbols[i].stringof.replace("this.", "");
            alias SymbolType = typeof(symbols[i]);
            enum FilePath = ConfigPath(getUDAs!(symbols[i], config)[0].filePath);

            ConfigManager().connect(&this.setValue!(FilePath, SymbolName));
            ConfigManager().getFile(FilePath).load();
        }}
    }
    
    private void setValue(ConfigPath FilePath, string SymbolName, SymbolType)(ConfigPath path, string name, JSONValue value) {
        import std.stdio;
        if (FilePath != path) return;
        if (SymbolName != name) return;
        mixin("this." ~ SymbolName) = ConfigValue!(SymbolType).conv(name, value);
    }
}
