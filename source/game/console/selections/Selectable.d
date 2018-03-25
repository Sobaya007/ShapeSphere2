module game.console.selections.Selectable;

import sbylib;
import game.console.selections.TokenList;
import std.format;

interface Selectable {
    string name();
    Selectable[] childs();
    Maybe!string order(string);
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
        import std.algorithm : map;
        import std.array : empty, front, popFront, array;

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

    final auto filterCandidates(string[] candidates, string current) {
        import std.algorithm : filter;
        import std.string : startsWith, toLower;
        import std.array : array;
  
        return candidates.filter!(s => s.toLower.startsWith(current.toLower)).array;
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

    mixin template ImplCountChild(bool flag) {

        override int countChilds() {
            import std.algorithm : map, sum, filter;

            return 
                flag ? 
                    childs
                    .filter!(child => child.isAggregate)
                    .map!(child => child.countChilds + 1).sum
                    : 0;
        }

        override bool isAggregate() {
            return flag;
        }
    }
}
