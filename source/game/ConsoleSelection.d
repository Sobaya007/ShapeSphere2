module game.ConsoleSelection;

import sbylib;
import game.Game;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio, std.ascii;

struct TokenList {
    string[] strs;

    string popFront() {
        auto result = strs.front.strip;
        strs.popFront();
        return result;
    }

    bool empty() {
        return strs.empty;
    }
}

interface Selectable {
    string[] childNames();
    Selectable[] findChild(string);
    Maybe!string order(string);
    string getInfo();
    string assign(string);

    final string interpret(TokenList tokens) {
        if (tokens.empty) return getInfo();
        auto token = tokens.popFront();
        if (token == ">") {
            if (tokens.empty) return "Put <name> after '>'";

            auto name = tokens.popFront(); 
            auto res = search(name);
            if (auto next = res.peek!Selectable) {
                return next.interpret(tokens);
            } else {
                return order(name).getOrElse(*res.peek!string);
            }

        } else if (token == "=") {
            if (tokens.empty) return "Put <value> after '='";

            auto val = tokens.popFront();

            if (!tokens.empty) return format!"Invalid token: '%s'"(tokens.popFront());

            return assign(val);
        }
        return format!"Invalid token: '%s'"(token);
    }

    final string[] candidates(TokenList tokens, string before) {
        if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;
        auto token = tokens.popFront();

        if (token == ">") {
            if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;

            auto name = tokens.popFront();

            if (auto next = search(name).peek!Selectable) {
                return next.candidates(tokens, before~name~">");
            } else {
                return filterCandidates(summarySameName(childNames), name).map!(s => before~s).array;
            }
        }
        return [];
    }

    final Algebraic!(Selectable, string) search(string name) {
        auto r = ctRegex!"\\[([0-9]*)\\]";
        auto c = matchFirst(name, r);
        if (!c.empty) {
            try {
                auto children = findChild(c.pre);
                if (children.empty) return typeof(return)(format!"No match name for '%s"(c.pre));
                auto res = children.drop(c.hit.dropOne.dropBackOne.to!int);
                if (res.empty) return typeof(return)(format!"There are only %d '%s'."(children.length, c.pre));
                return typeof(return)(res.front);
            } catch (ConvException) {
                return typeof(return)("Cannot interpret <index>.");
            }
        } else {
            auto res = findChild(name);
            if (res.empty) return typeof(return)(format!"No match name for '%s"(name));
            if (res.length > 1) return typeof(return)(format!"There are %d %s. Please select like <name>[<index>]."(res.length, name));
            return typeof(return)(res.front);
        }
    }

    final auto summarySameName(string[] candidates) {
        return candidates.sort.group.map!(g => g[1] == 1 ? g[0] : g[0]~"[").array;
    }

    final auto filterCandidates(string[] candidates, string current) {
        return candidates.filter!(s => s.toLower.startsWith(current.toLower)).array;
    }
}

class RootSelection : Selectable {
    override string[] childNames() {
        return ["world3d", "world2d", "save", "quit"];
    }

    override Selectable[] findChild(string name) {
        if (name == "world3d") return [new WorldSelection(Game.getWorld3D)];
        if (name == "world2d") return [new WorldSelection(Game.getWorld2D)];
        return null;
    }

    override Maybe!string order(string code) {
        if (code == "save") {
            Game.getMap().save();
            return Just("Saved.");
        }
        if (code == "quit") {
            Game.getCommandManager().save();
            Core().end();
        }
        return None!string;
    }

    override string getInfo() {
        return null;
    }

    override string assign(string) {
        return "Cannot assign to root.";
    }
}

class WorldSelection : Selectable {

    private World world;

    this(World world) {this.world = world;}

    override string[] childNames() {
        return world.getEntities.filter!(e => e.getParent.isNone).map!(e => e.name).array;
    }

    override Selectable[] findChild(string name) {
        return world.getEntities.filter!(e => e.getParent.isNone).filter!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
    }

    override string getInfo() {
        return world.toString((Entity e) => e.name, false).split("\n").sort.group.map!(p => p[1] == 1 ? p[0] : format!"%s[%d]"(p[0], p[1])).join("\n");
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to World.";
    }
}

class EntitySelection : Selectable {

    private Entity entity;

    this(Entity entity) {this.entity = entity;}

    override string[] childNames() {
        return entity.getChildren.map!(e => e.name).array ~ ["pos", "rot", "scale"];
    }

    override Selectable[] findChild(string name) {
        if (name == "pos") return [new VectorSelection(entity.pos)];
        auto res = entity.getChildren.filter!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
        return res;
    }

    override string getInfo() {
        return entity.toString(false);
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to Entity.";
    }
}

class VectorSelection : Selectable {
    private ChangeObserved!vec3* vec;
    this(ref ChangeObserved!vec3 vec) {this.vec = &vec;}

    override string[] childNames() {
        return ["x", "y", "z"];
    }

    override Selectable[] findChild(string name) {
        if (name == "x") return [new FloatSelection(this.vec.x)];
        if (name == "y") return [new FloatSelection(this.vec.y)];
        if (name == "z") return [new FloatSelection(this.vec.z)];
        return null;
    }

    override string getInfo() {
        return vec.toString;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        val = val.strip;
        if (!val.startsWith("(")) return "<vector> must start with '('";
        if (!val.endsWith(")")) return "<vector> must end with ')'";
        auto values = val[1..$-1].split(",").to!(float[]);
        scope (failure) return format!"Cannot interpret '%s' as vector"(val);
        if (values.length != 3) return format!"<vector> must have just 3 elements. not %d."(values.length);
        *vec = vec3(values);
        return getInfo();
    }
}

class FloatSelection : Selectable {
    private ChangeObserved!(float*) elem;
    this(ChangeObserved!(float*) elem) {this.elem = elem;}

    override string[] childNames() {
        return null;
    }

    override Selectable[] findChild(string name) {
        return null;
    }

    override string getInfo() {
        return elem.get.to!string;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        auto value = val.strip.to!float;
        scope (failure) return format!"Cannot interpret '%s' as <float>"(val.strip);
        elem = value;
        return getInfo();
    }
}
