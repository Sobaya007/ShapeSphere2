module sbylib.control.GuiControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse2D;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.camera.OrthoCamera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
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
            auto controllable = getCollidedControllable();
            if (controllable !is null) {
                this.colEntry[this.mouse.justPressedButton()] = controllable;
                controllable.onMousePressed(this.mouse.justPressedButton());
            }
        }
        if (this.mouse.justReleased()) {
            auto mouseButton = this.mouse.justReleasedButton();
            if (mouseButton in this.colEntry && this.colEntry[mouseButton] !is null) {
                auto controllable = getCollidedControllable();
                this.colEntry[mouseButton].onMouseReleased(mouseButton, controllable is this.colEntry[mouseButton]);
            }

            this.colEntry[mouseButton] = null;
        }
        foreach (controllable; this.controllables) {
            controllable.update(this.mouse);
        }
    }

    void add(IControllable controllable) {
        this.controllables ~= controllable;
        this.world.add(controllable.getEntity());
    }

    private IControllable getCollidedControllable() {
        import std.algorithm, std.math, std.array;

        Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
        auto colInfos = this.world.calcCollideRay(this.ray).filter!(a => !a.colDist.isNaN).array;
        if (colInfos.length == 0) return null;
        auto colInfo = colInfos.minElement!(a => a.colDist);
        if (!colInfo.collided) return null;

        auto entity = colInfo.colEntry.getOwner;
        while(entity.getUserData() is null) {
            entity = entity.getParent;
        }
        return cast(IControllable)entity.getUserData;
    }
}
