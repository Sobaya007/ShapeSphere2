module sbylib.control.GuiControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.core.Window;
import sbylib.input.Mouse2D;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.camera.OrthoCamera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.utils.Lazy;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;
import sbylib.core.World;
import sbylib.core.Process;
import sbylib.control.IControllable;

class GuiControl {

    private Mouse2D mouse;
    private IControllable[MouseButton] colEntry;
    private World world;
    private CollisionRay ray;
    private OrthoCamera camera;
    private IControllable[] controllables;

    this(Window window, OrthoCamera camera, World world) {
        this.ray = new CollisionRay();
        this.mouse = new Mouse2D(window, camera);
        this.world = world;
        this.camera = camera;
    }

    void update(Process proc) {
        this.mouse.update();
        if (this.mouse.justPressed()) {
            Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
            auto colInfos = this.world.calcCollideRay(this.ray);
            if (colInfos.length == 0) return;
            import std.algorithm;
            auto colInfo = colInfos.minElement!(a => a.colDist);
            if (!colInfo.collided) return;
            if (auto con = cast(IControllable)colInfo.colEntry.getOwner().getRootParent().getUserData) {
                this.colEntry[this.mouse.justPressedButton()] = con;
                con.onMousePressed(this.mouse.justPressedButton());
            }
        }
        if (this.mouse.justReleased()) {
            if (this.mouse.justReleasedButton() in this.colEntry
                && this.colEntry[this.mouse.justReleasedButton()] !is null) {
                this.colEntry[this.mouse.justReleasedButton()].onMouseReleased(this.mouse.justReleasedButton());
                this.colEntry[this.mouse.justReleasedButton()] = null;
            }
        }
        foreach (con; this.controllables) {
            con.update(this.mouse);
        }
    }

    void add(IControllable con) {
        this.controllables ~= con;
        this.world.add(con.getEntity());
    }
}
