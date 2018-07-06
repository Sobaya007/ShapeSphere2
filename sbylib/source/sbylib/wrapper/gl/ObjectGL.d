module sbylib.wrapper.gl.ObjectGL;

class ObjectGL {
    private bool alive = true;
    public bool isAlive() const { return this.alive; }

    immutable uint id;

    this(uint id) {
        this.id = id;
    }

    this(uint id) immutable {
        this.id = id;
    }

    ~this() {
        import std.stdio;
        if (isAlive) writeln("Invalid Destruction For " ~ typeof(this).stringof);
    }

    void destroy() 
        in(this.isAlive)
    {
        this.alive = false;
    }
}
