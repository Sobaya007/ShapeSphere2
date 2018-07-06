module sbylib.wrapper.gl.GL;

import derelict.opengl;

class GL {
    
    package(sbylib) static GLVersion glVersion;

    private this(){}

    public static void init() {
        DerelictGL3.load();
    }

    public static int getShaderVersion() in {
        assert(glVersion >= GLVersion.gl20);
    } body {
        switch(glVersion) {
            case GLVersion.gl20:
                return 110;
            case GLVersion.gl21:
                return 120;
            case GLVersion.gl30:
                return 130;
            case GLVersion.gl31:
                return 140;
            case GLVersion.gl32:
                return 150;
            default:
                return glVersion * 10;
        }
    }
}
