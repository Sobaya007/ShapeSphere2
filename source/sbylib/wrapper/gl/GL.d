module sbylib.wrapper.gl.GL;

import derelict.opengl;

class GL {
    
    private this(){}

    public static void init() {
        DerelictGL3.load();
    }
}
