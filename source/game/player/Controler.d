module game.player.Controler;

import sbylib;
import std.math;

enum ControlerButton {
    Down,
    Needle,
    Spring,
    CameraLeft,
    CameraRight,
    CameraReset,
    LookOver
}

class Controler {

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

    private Key key;
    private JoyStick joy;
    private Button[ControlerButton] buttons;
    private Stick leftStick;
    private Stick rightStick;

    this(Key key, JoyStick joy) {
        this.key = key;
        this.joy = joy;
        this.buttons[ControlerButton.Down] = Button(KeyButton.Space, JoyButton.B);
        this.buttons[ControlerButton.Needle] = Button(KeyButton.KeyX, JoyButton.X);
        this.buttons[ControlerButton.Spring] = Button(KeyButton.KeyC, JoyButton.Y);
        this.buttons[ControlerButton.CameraLeft] = Button(KeyButton.KeyQ, JoyButton.L1);
        this.buttons[ControlerButton.CameraRight] = Button(KeyButton.KeyE, JoyButton.R1);
        this.buttons[ControlerButton.CameraReset] = Button(KeyButton.KeyZ, JoyButton.R3);
        this.buttons[ControlerButton.LookOver] = Button(KeyButton.KeyR, JoyButton.L2);
        this.leftStick = Stick(KeyButton.Left, KeyButton.Right, KeyButton.Up, KeyButton.Down, JoyAxis.LeftX, JoyAxis.LeftY);
        this.rightStick = Stick(KeyButton.KeyA, KeyButton.KeyD, KeyButton.KeyW, KeyButton.KeyS, JoyAxis.RightX, JoyAxis.RightY);
    }

    bool isPressed(ControlerButton b) {
        if (this.joy.canUse) {
            return this.joy.isPressed(this.buttons[b].joyButton);
        } else {
            return this.key.isPressed(this.buttons[b].keyButton);
        }
    }

    bool isReleased(ControlerButton b) {
        if (this.joy.canUse) {
            return this.joy.isReleased(this.buttons[b].joyButton);
        } else {
            return this.key.isReleased(this.buttons[b].keyButton);
        }
    }

    bool justPressed(ControlerButton b) {
        if (this.joy.canUse) {
            return this.joy.justPressed(this.buttons[b].joyButton);
        } else {
            return this.key.justPressed(this.buttons[b].keyButton);
        }
    }

    bool justReleased(ControlerButton b) {
        if (this.joy.canUse) {
            return this.joy.justReleased(this.buttons[b].joyButton);
        } else {
            return this.key.justReleased(this.buttons[b].keyButton);
        }
    }

    vec2 getLeftStickValue() {
        return this.getStickValue(this.leftStick);
    }
  
    vec2 getRightStickValue() {
        return this.getStickValue(this.rightStick);
    }

    private vec2 getStickValue(Stick stick) {
        vec2 v = vec2(0);
        if (this.joy.canUse) {
            v.x = this.joy.getAxis(stick.joyAxisX);
            v.y = this.joy.getAxis(stick.joyAxisY);
            if (abs(v.x) < 1.1 / 128) v.x = 0;
            if (abs(v.y) < 1.1 / 128) v.y = 0;
        } else {
            if (key.isPressed(stick.keyLeft)) v.x--;
            if (key.isPressed(stick.keyRight)) v.x++;
            if (key.isPressed(stick.keyUp)) v.y--;
            if (key.isPressed(stick.keyDown)) v.y++;
        }
        return v;
    }
}
