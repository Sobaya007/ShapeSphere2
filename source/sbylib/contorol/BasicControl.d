module sbylib.control.BasicControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;

class BasicControl {

    private Mouse mouse;
    private Object3D obj;

    this(Object3D obj) {
        this.mouse = new Mouse();
        this.obj = obj;
    }

    void update(Window window, Camera camera) {
        this.mouse.update(window);
        auto dif2 = this.mouse.getDif();
        if (dif2.length < 0.01) return;
        if (this.mouse.isPressed(MouseButton.Button1)) {
            // Translation
            auto dif4 = vec4(dif2.x,-dif2.y, 0, 0);
            auto dif3 = (camera.worldMatrix.get() * dif4).xyz;
            obj.pos += dif3 * 0.005;
        } else if (this.mouse.isPressed(MouseButton.Button2)) {
            auto axisV = cross(vec3(dif2.x, -dif2.y, 0), vec3(0,0,1));
            auto axisW = (camera.worldMatrix.get() * vec4(axisV, 0)).xyz;
            auto rot = mat3.axisAngle(normalize(axisW), length(axisW) * 0.01);
            obj.rot = rot * obj.rot;
        }
    }
}
