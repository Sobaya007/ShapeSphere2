module game.stage.crystalMine.component.Root;

/*

   {
        "Areas" : array,
        "StageName": string
        "StartArea" : string
   }



*/

class Root {

    import std.json;
    import std.file : readText;
    import std.algorithm : find;
    import sbylib;
    import game.stage.crystalMine.component.Area;
    import game.stage.crystalMine.component.CameraMove;

    enum path = "Resource/stage/Stage1.json";

    private Area area;
    private JSONValue root;

    this() {
        this.load();
        this.transit(startArea);
    }

    auto obj() {
        return root.object();
    }

    string stageName() {
        return obj["StageName"].str();
    }

    string startArea() {
        return obj["StartArea"].str();
    }

    void startArea(string s) {
        obj["StartArea"] = s;
    }

    auto cameraMove() {
        return CameraMove(obj["CameraMove"].object());
    }

    auto areas() {
        import std.range : iota;
        import std.algorithm : map;

        auto root = obj["Areas"].array;
        return root.length.iota.map!(i => Area(this.root, i, root));
    }

    auto currentArea() {
        return area;
    }

    void transit(string name) {
        auto next = this.areas.find!(a => a.name == name).front;
        next.load();
        this.area = next;
    }

    void reload() {
        this.load();
        this.area = this.areas.find!(a => a.name == this.currentArea.name).front;
    }

    void save() {
        import std.file : write;
        write(path, root.toJSON(true));
    }

    private void load() {
        this.root = parseJSON(readText(path)).object();
    }
}
