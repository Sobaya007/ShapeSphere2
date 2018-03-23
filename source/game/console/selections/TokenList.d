module game.console.selections.TokenList;

struct TokenList {
    string[] strs;

    string popFront() {
        import std.string : strip;
        import std.array : front, popFront;

        auto result = strs.front.strip;
        strs.popFront();
        return result;
    }

    bool empty() {
        import std.array : empty;
        return strs.empty;
    }
}
