module game.stage.crystalMine.component.Component;

import std.math;
import std.variant;

alias JsonKey = Algebraic!(size_t, string);
alias Path = immutable JsonKey[];

mixin template Component(Class, string[string] structure) {
    import std.json, std.typecons;
    import sbylib;
    import std.variant;

    private JSONValue root;
    private Path path;
    private Entity parent;
    private static Class[Path] _reserved;

    this(JSONValue root, Path path, Entity parent) {
        this.root = root;
        this.path = path;
        this.parent = parent;
        static foreach (name, type; structure) {
            mixin(format!"this.%s = %s;"(name, name));
        }
        this.entity();
    }

    void create() {

        auto e = new Class;

        this.parent.addChild(e);

        reserved = e;

        import game.tool.manipulator;
        e.setUserData("Manipulator", new ManipulatorTarget); // temp
    }

    auto ref reserved() {
        if (path !in _reserved) _reserved[path] = null;
        return _reserved[path];
    }

    Class entity() {
        if (reserved is null) create();
        return reserved;
    }

    auto obj() {
        JSONValue value = root;
        foreach (key; path) {
            key.visit!(
                (size_t i) => value = value.array[i],
                (string s) => value = value.object[s]
            );
        }
        return value.object();
    }

    static foreach (name, type; structure) {
        import std.traits : isInstanceOf;
        import std.format;
        import sbylib.utils.Functions : as;
        import sbylib.math.Vector;
        mixin(format!"alias T_%s = %s;"(name, type));

        static if (isInstanceOf!(Vector, mixin("T_"~name))) {
            mixin(format!"alias S_%s = float[];"(name));
        } else {
            mixin(format!"alias S_%s = T_%s;"(name, name));
        }

        mixin(format!q{
            %s %s() {
                return %s(obj["%s"].as!(%s));
            }
        }(type, name, type, name, mixin("S_"~name).stringof));

        mixin(format!q{
            void %s(%s %s) {
                obj["%s"] = cast(%s)(%s);
                entity.%s = %s;
            }
        }(name, type, name, name, mixin("S_"~name).stringof, name, name, name));
    }

    void remove() {
        this.entity.remove();
        this.entity.destroy();
    }
}
