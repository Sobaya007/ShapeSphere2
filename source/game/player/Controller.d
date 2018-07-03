module game.player.Controller;

import sbylib;
import std.math;

enum CButton {
    Press,
    Needle,
    Spring,
    CameraReset,
    LookOver,
    Left,
    Right,
    Up,
    Down,
    Decide,
    Cancel
}

class Controller {

    struct Button {
        KeyButton keyButton;
        JoyButton joyButton;
    }

    struct Stick {
        KeyButton keyLeft;
        KeyButton keyRight;
        KeyButton keyUp;
        KeyButton keyDown;
        JoyAxis joyAxisX;
        JoyAxis joyAxisY;
    }

    private Button[CButton] buttons;
    private Stick leftStick;
    private Stick rightStick;
    debug bool available = true;

    private static Controller instance;
    public static Controller opCall() {
        if (instance is null)
            return instance = new Controller();
        return instance;
    }

    private this() {
        this.buttons[CButton.Press] = Button(KeyButton.Space, JoyButton.B);
        this.buttons[CButton.Needle] = Button(KeyButton.KeyX, JoyButton.X);
        this.buttons[CButton.Spring] = Button(KeyButton.KeyC, JoyButton.Y);
        this.buttons[CButton.CameraReset] = Button(KeyButton.KeyZ, JoyButton.R3);
        this.buttons[CButton.LookOver] = Button(KeyButton.KeyR, JoyButton.L2);
        this.buttons[CButton.Left] = Button(KeyButton.Left, JoyButton.Left);
        this.buttons[CButton.Right] = Button(KeyButton.Right, JoyButton.Right);
        this.buttons[CButton.Up] = Button(KeyButton.Up, JoyButton.Up);
        this.buttons[CButton.Down] = Button(KeyButton.Down, JoyButton.Down);
        this.buttons[CButton.Decide] = Button(KeyButton.Enter, JoyButton.A);
        this.buttons[CButton.Cancel] = Button(KeyButton.BackSpace, JoyButton.B);
        this.leftStick = Stick(KeyButton.Left, KeyButton.Right, KeyButton.Up, KeyButton.Down, JoyAxis.LeftX, JoyAxis.LeftY);
        this.rightStick = Stick(KeyButton.KeyA, KeyButton.KeyD, KeyButton.KeyW, KeyButton.KeyS, JoyAxis.RightX, JoyAxis.RightY);
    }

    bool isPressed(CButton b) {
        debug if (!available) return false;
        if (Core().joyCanUse()) {
            return Core().isPressed(this.buttons[b].joyButton);
        } else {
            return Core().isPressed(this.buttons[b].keyButton);
        }
    }

    bool isReleased(CButton b) {
        debug if (!available) return true;
        if (Core().joyCanUse()) {
            return Core().isReleased(this.buttons[b].joyButton);
        } else {
            return Core().isReleased(this.buttons[b].keyButton);
        }
    }

    bool justPressed(CButton b) {
        debug if (!available) return false;
        if (Core().joyCanUse) {
            return Core().justPressed(this.buttons[b].joyButton);
        } else {
            return Core().justPressed(this.buttons[b].keyButton);
        }
    }

    bool justReleased(CButton b) {
        debug if (!available) return true;
        if (Core().joyCanUse()) {
            return Core().justReleased(this.buttons[b].joyButton);
        } else {
            return Core().justReleased(this.buttons[b].keyButton);
        }
    }

    vec2 getLeftStickValue() {
        return this.getStickValue(this.leftStick);
    }
  
    vec2 getRightStickValue() {
        return this.getStickValue(this.rightStick);
    }

    private vec2 getStickValue(Stick stick) {
        debug if (!available) return vec2(0);
        vec2 v = vec2(0);
        if (Core().joyCanUse()) {
            v.x = Core().getAxis(stick.joyAxisX);
            v.y = Core().getAxis(stick.joyAxisY);
            if (abs(v.x) < 1.1 / 128) v.x = 0;
            if (abs(v.y) < 1.1 / 128) v.y = 0;
        } else {
            if (Core().isPressed(stick.keyLeft)) v.x--;
            if (Core().isPressed(stick.keyRight)) v.x++;
            if (Core().isPressed(stick.keyUp)) v.y--;
            if (Core().isPressed(stick.keyDown)) v.y++;
        }
        return v;
    }
}
