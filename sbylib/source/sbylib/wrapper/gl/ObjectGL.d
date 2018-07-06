module sbylib.wrapper.gl.ObjectGL;

import sbylib.core.Core;
import sbylib.core.Process;

class ObjectGL {

    immutable uint id;
    private Process destroyProc;

    this(uint id, void function(uint) f) {
        this.id = id;
        this.destroyProc = Core().addProcess(delegate(Process proc) {
            f(id);
            proc.kill();
        }, "destroy");
        this.destroyProc.pause();
    }

    this(uint id, void function(uint) destroy) immutable {
        this.id = id;
    }

    ~this() {
        if (this.destroyProc !is null) {
            this.destroyProc.resume();
        }
    }
}
