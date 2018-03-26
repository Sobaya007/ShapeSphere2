module game.console.selections.Selectable;

import sbylib;
import game.console.selections.TokenList;
import std.format;

interface Selectable {
    string name();
    Selectable parent();
    Selectable[] childs();
    string getInfo();
    string assign(string);
    int countChilds();
    bool isAggregate();

    final string interpret(TokenList tokens) {
        if (tokens.empty) return getInfo();
        auto token = tokens.popFront();
        if (token == ">") {
            if (tokens.empty) return "Put <name> after '>'";

            auto name = tokens.popFront(); 
            auto res = search(name);
            if (auto next = res.peek!Selectable) {
                return next.interpret(tokens);
            } 
            return *res.peek!string;
        } else if (token == "=") {
            if (tokens.empty) return "Put <value> after '='";

            auto val = tokens.popFront();

            if (!tokens.empty) return format!"Invalid token: '%s'"(tokens.popFront());

            return assign(val);
        }
        return format!"Invalid token: '%s'"(token);
    }

    final Selectable[] candidates(TokenList tokens) {
        import std.algorithm : map;
        import std.array : empty, front, popFront, array;

        if (tokens.empty) return childs;
        auto token = tokens.popFront();

        if (token == ">") {
            if (tokens.empty) return childs;

            auto name = tokens.popFront();

            if (auto next = search(name).peek!Selectable) {
                return next.candidates(tokens);
            } else {
                return filterCandidates(childs, name);
            }
        }
        return [];
    }

    final Algebraic!(Selectable, string) search(string name) {
        import std.regex;
        import std.array : empty, front;
        import std.range : drop, dropOne, dropBackOne;
        import std.conv;

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
        import std.algorithm : sort, group, map;
        import std.array : array;

        return candidates.sort.group.map!(g => g[1] == 1 ? g[0] : g[0]~"[").array;
    }

    final auto filterCandidates(Selectable[] candidates, string current) {
        import std.algorithm : filter;
        import std.string : startsWith, toLower;
        import std.array : array;
  
        return candidates.filter!(s => s.name.toLower.startsWith(current.toLower)).array;
    }

    final string[] childNames() {
        import std.algorithm : map;
        import std.array : array;

        return childs.map!(child => child.name).array;
    }

    final Selectable[] findChild(string name) {
        import std.algorithm : filter;
        import std.array : array;

        return childs.filter!(child => child.name == name).array;
    }

    final string screenName() {
        import std.format;

        auto cnt = countChilds();
        if (cnt == 0) return name;
        return format!"%s(%d)"(name, cnt);
    }

    final string absoluteName() {
        if (parent is null) return name;
        return parent.absoluteName ~ ">" ~ name;
    }

    final string indexedName() {
        import std.algorithm : filter, countUntil, sort, find;
        import std.range;
        import std.array : array;
        import std.format : format;

        if (parent is null) return name;
        auto sameNames = parent.childs.sort!((a,b) => a.name < b.name).filter!(child => child.name == this.name).array;
        if (sameNames.length == 1) return name; 

        auto index = sameNames.countUntil!(a => a is this);
        return format!"%s[%d]"(name, index);
    }

    mixin template ImplCountChild(bool flag) {

        override int countChilds() {
            import std.algorithm : map, sum, filter, max;

            return 
                isAggregate ? 
                    childs
                    .filter!(child => child.isAggregate)
                    .map!(child => max(1, child.countChilds)).sum
                    : 0;
        }

        override string getInfo() {
            import std.algorithm : sort, group, map;
            import std.format;
            import std.array : join, split, array;

            return childs
                .sort!"a.name < b.name".array
                .group!"a.name==b.name"
                .map!(p => p[1] > 1 ? format!"%s[%d]"(p[0].name, p[1]) : p[0].screenName)
                .join("\n");
        }

        override bool isAggregate() {
            return flag;
        }
    }
}
