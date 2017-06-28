module sbylib.control.CameraControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;

class CameraControl {

    private Mouse mouse;
    private Watch!Camera camera;
    vec3 focus;

    this(Watch!Camera camera) {
        this.mouse = new Mouse();
        this.camera = camera;
        this.focus = vec3(0);
    }

    void update(Window window, Watch!Camera camera) {
//        this.mouse.update(window);
//        auto dif2 = this.mouse.getDif();
//        if (dif2.length < 0.01) return;
//        if (this.mouse.isPressed(MouseButton.Button1)) {
//            // Translation
//            auto dif4 = vec4(dif2.x,-dif2.y, 0, 0);
//            auto dif3 = (camera.getObj().worldMatrix.get() * dif4).xyz;
//            focus += dif3 * 0.005;
//        } else if (this.mouse.isPressed(MouseButton.Button2)) {
//            auto axisV = cross(vec3(dif2.x, -dif2.y, 0), vec3(0,0,1));
//            auto axisW = (camera.getObj().worldMatrix.get() * vec4(axisV, 0)).xyz;
//            auto rot = mat3.axisAngle(normalize(axisW), length(axisW) * 0.01);
//            obj.rot = rot * obj.rot;
//        }
    }
}
