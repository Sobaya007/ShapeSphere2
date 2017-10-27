module game.player.Controler;

import sbylib;
import std.math;

enum ControlerButton {
    Down,
    Needle,
    Spring
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

    this(Key key, JoyStick joy) {
        this.key = key;
        this.joy = joy;
        this.buttons[ControlerButton.Down] = Button(KeyButton.Space, JoyButton.X);
        this.buttons[ControlerButton.Needle] = Button(KeyButton.KeyX, JoyButton.Y);
        this.buttons[ControlerButton.Spring] = Button(KeyButton.KeyC, JoyButton.A);
        this.leftStick = Stick(KeyButton.Left, KeyButton.Right, KeyButton.Up, KeyButton.Down, JoyAxis.LeftX, JoyAxis.LeftY);
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
        vec2 v = vec2(0);
        if (this.joy.canUse) {
            v.x = this.joy.getAxis(JoyAxis.LeftX);
            v.y = this.joy.getAxis(JoyAxis.LeftY);
            if (abs(v.x) < 1.1 / 128) v.x = 0;
            if (abs(v.y) < 1.1 / 128) v.y = 0;
        } else {
            if (key.isPressed(KeyButton.Left)) v.x--;
            if (key.isPressed(KeyButton.Right)) v.x++;
            if (key.isPressed(KeyButton.Up)) v.y--;
            if (key.isPressed(KeyButton.Down)) v.y++;
        }
        return v;
    }
}
