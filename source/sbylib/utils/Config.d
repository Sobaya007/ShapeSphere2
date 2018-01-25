module sbylib.utils.Config;

import std.json;
import sbylib.utils.Path;
import std.traits;

class ConfigManager {

    import std.signals;
    import sbylib.utils.Functions;

    mixin Signal;
    mixin Signal!(ConfigPath, string, JSONValue);
    mixin Utils.Singleton;

    private ConfigFile[] files;

    void load() {
        emit();
    }

    void setValue(ConfigPath path, string name, JSONValue val) {
        emit(path, name, val);
    }

    ConfigFile getFile(ConfigPath path) {
        import std.algorithm : find;
        import std.array;
        auto findResult = this.files.find!(file => file.path == path);
        if (!findResult.empty) return findResult.front;
        auto newFile = new ConfigFile(path);
        this.files ~= newFile;
        return newFile;
    }
}

class ConfigFile {

    private ConfigPath path;

    private this(ConfigPath path) {
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

    void setValue(ConfigPath path, string name, JSONValue value) {
        if (this.path != path) return;
        if (this.name != name) return;
        this.value = conv(value);
    }

    auto conv(JSONValue value) {
        switch (value.type) {
            case JSON_TYPE.FLOAT:
                static if (isFloatingPoint!(Type)) {
                    return value.floating();
                } else {
                    break;
                }
            case JSON_TYPE.INTEGER:
                static if (isNumeric!(Type)) {
                    return cast(Type)value.integer();
                } else {
                    break;
                }
            case JSON_TYPE.UINTEGER:
                static if (isNumeric!(Type)) {
                    return cast(Type)value.uinteger();
                } else {
                    break;
                }
            case JSON_TYPE.STRING:
                static if (isSomeString!(Type)) {
                    return value.str();
                } else {
                    break;
                }
            case JSON_TYPE.TRUE:
                static if (is(Type == bool)) {
                    return true;
                } else {
                    break;
                }
            case JSON_TYPE.FALSE:
                static if (is(Type == bool)) {
                    return false;
                } else {
                    break;
                }
            case JSON_TYPE.ARRAY:
                static if (isArray!(Type)) {
                    import std.algorithm : map;
                    import std.arary;
                    return this.value.array().map!(this.conv).array;
                } else {
                    break;
                }
            default:
                import std.format;
                assert(false, format!"Type '%s' is not allowed."(value.type));
        }
                import std.format;
        assert(false, format!"Expected Type is '%s', but %s's type is '%s'."(Type.stringof, this.name, value.type));
    }

    auto ref getValue() {
        if (!initialized) {
            this.initialize();
            this.initialized = true;
        }
        return this.value;
    }

    static if (isCopyable!Type) {
        import std.typecons;
        mixin Proxy!(getValue);
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
