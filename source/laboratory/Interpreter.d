module laboratory.Interpreter;

import sbylib;
import laboratory.LaboratoryConsole;
import core.thread : Fiber;

private enum command;
private alias Command = void delegate();

class Performer {

    enum APPLICATION_OUTPUT_COLOR = vec3(0,1,0.2);
    private LaboratoryConsole console;
    private World world;
    private Fiber fiber;
    private string input;
    string[] candidates;

    this(LaboratoryConsole console, World world) {
        this.console = console;
        this.world = world;
    }

    Maybe!(Performer) step(string input)
        in(this.fiber !is null)
        in(this.fiber.state != Fiber.State.TERM)
    {
        this.input = input;
        this.fiber.call();
        if (this.fiber.state == Fiber.State.TERM) {
            this.fiber = null;
            return None!(Performer);
        }
        return Just(this);
    }

    private void start(void delegate() f) {
        this.candidates = null;
        this.fiber = new Fiber(f);
        this.step("");
    }

    void stop() {
        this.fiber = null;
    }

    @command void clear() {
        string groupName = "regular";
        start({
            writefln!("input groupName (default =%s)")(groupName);
            setCandidates(world.getRenderGroupNames() ~ "");
            auto input = this.getInput();
            if (input != "") groupName = input;
            world.clear(groupName);
        });
    }

    @command void addEntity() {
        start({
            import std.traits : staticMap;

            alias getList(T) = T.List;

            alias Geoms = staticMap!(getList, Universe.DefaultGeometryList);
            alias Matls = staticMap!(getList, Universe.DefaultMaterialList);

            string[] gcs;
            static foreach (Geom; Geoms) {
                gcs ~= Geom.Name;
            }
            setCandidates(gcs);

            string geometry;
            do {
                writefln!("input geometry name");
                geometry = this.getInput();
            } while (!isCorrectInput(geometry));

            string[] mcs;
            static foreach (Mat; Matls) {
                mcs ~= Mat.Name;
            }
            setCandidates(mcs);
            string material;
            do {
                writefln!("input material name");
                material = this.getInput();
            } while (!isCorrectInput(material));

            static foreach(Geom; Geoms) {
                if (Geom.Name == geometry) {
                    static foreach (Mat; Matls) {
                        if (Mat.Name == material) {
                            auto entity = doInGlThread(makeEntity(Geom.Type.create(), new Mat.Type));
                            entity.name = Geom.Name ~ ":" ~ Mat.Name;
                            world.add(entity);
                            return;
                        }
                    }
                }
            }
        });
    }

    @command void quit() {
        Core().end();
    }

    private Command[string] getCommands() {
        Command[string] result;
        import std.traits;
        static foreach (symbol; getSymbolsByUDA!(Performer, command)) {{
            static assert(symbol.stringof[0..5] == "this.");
            static assert(symbol.stringof[$-2..$] == "()");
            result[symbol.stringof[5..$-2]] = &symbol;
        }}
        return result;
    }

    private string getInput() {
        Fiber.yield();
        return this.input;
    }

    private auto doInGlThread(T)(lazy T value) {
        T result;
        Core().addProcess((Process proc) {
            result = value;
            console.stepPerformer();
            proc.kill();
        }, "work");
        Fiber.yield();
        return result;
    }

    void writefln(string fmt, Args...)(Args args) {
        console.show(format!fmt(args).colored(APPLICATION_OUTPUT_COLOR));
    }

    void setCandidates(string[] candidates) {
        this.candidates = candidates;
    }

    string[] getCandidates() {
        return this.fiber is null ? this.getCommands().keys : this.candidates;
    }

    bool isCorrectInput(string input) {
        import std.algorithm : canFind;

        auto candidates = this.getCandidates();
        return candidates.canFind(input);
    }
}

class Interpreter {

    private Performer performer;

    this(LaboratoryConsole console, World world) {
        this.performer = new Performer(console, world);
    }

    string[] getCommandNames() {
        return this.performer.getCommands().keys;
    }

    bool isCorrectInput(string input) {
        return this.performer.isCorrectInput(input);
    }

    Maybe!(Performer) interpret(string input) {
        auto commands = performer.getCommands();
        if (input in commands) {
            commands[input]();
            return Just(performer);
        }
        return None!(Performer);
    }

    string[] getCandidates() {
        return performer.getCandidates();
    }

    Maybe!string complete(string input) {
        return complete(input, getCandidates());
    }

    Maybe!string complete(string input, string[] candidates) {
        import std.algorithm : all, maxElement, commonPrefix;
        if (candidates.all!(name => commonPrefix(input, name).length == 0)) return None!string;
        return Just(candidates.maxElement!(name => commonPrefix(input, name).length));
    }
}
