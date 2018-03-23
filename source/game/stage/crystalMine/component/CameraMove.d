module game.stage.crystalMine.component.CameraMove;

struct CameraMove {

    import std.json, std.typecons;
    import sbylib;

    private size_t index;
    private JSONValue[string] obj;

    this(JSONValue[string] obj) {
        this.obj = obj;
    }

    auto trail() {
        import game.camera.behavior.TraceBehavior;
        import std.functional : pipe;
        import std.algorithm : map;
        import std.array : array;

        return obj["Trail"].array
            .map!(e => e.object()
                    .pipe!(o => TraceBehavior.Trail(vec3(o["pos"].as!(float[])), mat3(o["rot"].as!(float[]))))).array;
    }
}
