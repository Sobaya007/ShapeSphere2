module sbylib.wrapper.al.AL;

import derelict.openal.al;
import derelict.alure.alure;
import sbylib.setting;

class AL {
    
    static void init() {
        DerelictAL.load();
        DerelictALURE.load(ALURE_DLL_PATH);
        assert(alureInitDevice(null, null), "Failed to init alure!");
    }

    static void terminate() {
        alureShutdownDevice();
    }
}
