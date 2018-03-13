module game.ConsoleSelection;

import sbylib;
import game.Game;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

interface Selectable {
    string[] childNames();
    Selectable[] findChild(string);
    string getInfo();

    final string interpret(string[] tokens) {
        if (tokens.empty) return getInfo();
        auto token = tokens.front;
        tokens.popFront();
        if (token == ">") {
            if (tokens.empty) return "Put <name> after '>'";

            auto name = tokens.front();
            tokens.popFront();

            auto next = search(name);

            return next.interpret(tokens).getOrElse(format!"No match name for '%s'"(name));
        }
        return format!"Invalid token: '%s'"(token);
    }

    final string[] candidates(string[] tokens, string before) {
        if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;
        auto token = tokens.front;
        tokens.popFront();
        if (token == ">") {
            if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;

            auto name = tokens.front();
            tokens.popFront();

            auto next = search(name);

            return next.candidates(tokens, before~name~">").getOrElse(filterCandidates(summarySameName(childNames), name).map!(s => before~s).array);
        }
        return [];
    }

    final Maybe!Selectable search(string name) {
        auto r = ctRegex!"\\[([0-9]*)\\]";
        auto c = matchFirst(name, r);
        if (!c.empty) {
            auto res = findChild(c.pre).drop(c.hit.dropOne.dropBackOne.to!int);
            return res.empty ? None!Selectable : Just(res.front);
        } else {
            auto res = findChild(name);
            return res.empty ? None!Selectable : Just(res.front);
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
        return ["world3d", "world2d"];
    }

    override Selectable[] findChild(string name) {
        if (name == "world3d") return [new WorldSelection(Game.getWorld3D)];
        if (name == "world2d") return [new WorldSelection(Game.getWorld2D)];
        return null;
    }

    override string getInfo() {
        return null;
    }
}

class WorldSelection : Selectable {

    private World world;

    this(World world) {this.world = world;}

    override string[] childNames() {
        return world.getEntities.map!(e => e.name).array;
    }

    override Selectable[] findChild(string name) {
        return world.getEntities.find!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
    }

    override string getInfo() {
        return world.toString((Entity e) => e.name, false).split("\n").sort.group.map!(p => p[1] == 1 ? p[0] : format!"%s[%d]"(p[0], p[1])).join("\n");
    }
}

class EntitySelection : Selectable {

    private Entity entity;

    this(Entity entity) {this.entity = entity;}

    override string[] childNames() {
        return entity.getChildren.map!(e => e.name).array ~ ["pos", "rot", "scale"];
    }

    override Selectable[] findChild(string name) {
        auto children = entity.getChildren.find!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
        if (!children.empty) return children;
        if (name == "pos") return [new PositionSelection(entity)];
        return null;
    }

    override string getInfo() {
        return entity.toString(false);
    }
}

class PositionSelection : Selectable {
    private Entity entity;
    this(Entity entity) {this.entity = entity;}

    override string[] childNames() {
        return ["x", "y", "z"];
    }

    override Selectable[] findChild(string name) {
        return null;
    }

    override string getInfo() {
        return entity.pos.toString;
    }
}
