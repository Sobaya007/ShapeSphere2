module sbylib.wrapper.glfw.Constants;

import derelict.glfw3.glfw3;

enum MouseButton {
    Button1 = GLFW_MOUSE_BUTTON_1,
    Button2 = GLFW_MOUSE_BUTTON_2,
    Button3 = GLFW_MOUSE_BUTTON_3,
}

enum KeyButton {
    KeyA = GLFW_KEY_A,
    KeyB = GLFW_KEY_B,
    KeyC = GLFW_KEY_C,
    KeyD = GLFW_KEY_D,
    KeyE = GLFW_KEY_E,
    KeyF = GLFW_KEY_F,
    KeyG = GLFW_KEY_G,
    KeyH = GLFW_KEY_H,
    KeyI = GLFW_KEY_I,
    KeyJ = GLFW_KEY_J,
    KeyK = GLFW_KEY_K,
    KeyL = GLFW_KEY_L,
    KeyM = GLFW_KEY_M,
    KeyN = GLFW_KEY_N,
    KeyO = GLFW_KEY_O,
    KeyP = GLFW_KEY_P,
    KeyQ = GLFW_KEY_Q,
    KeyR = GLFW_KEY_R,
    KeyS = GLFW_KEY_S,
    KeyT = GLFW_KEY_T,
    KeyU = GLFW_KEY_U,
    KeyV = GLFW_KEY_V,
    KeyW = GLFW_KEY_W,
    KeyX = GLFW_KEY_X,
    KeyY = GLFW_KEY_Y,
    KeyZ = GLFW_KEY_Z,

    Key0 = GLFW_KEY_0,
    Key1 = GLFW_KEY_1,
    Key2 = GLFW_KEY_2,
    Key3 = GLFW_KEY_3,
    Key4 = GLFW_KEY_4,
    Key5 = GLFW_KEY_5,
    Key6 = GLFW_KEY_6,
    Key7 = GLFW_KEY_7,
    Key8 = GLFW_KEY_8,
    Key9 = GLFW_KEY_9,

    Left = GLFW_KEY_LEFT,
    Right = GLFW_KEY_RIGHT,
    Up = GLFW_KEY_UP,
    Down = GLFW_KEY_DOWN,

    Comma = GLFW_KEY_COMMA,               /* , */
    Minus = GLFW_KEY_MINUS,               /* - */
    Period = GLFW_KEY_PERIOD,             /* . */
    Slash = GLFW_KEY_SLASH,               /* / */
    Semicolon = GLFW_KEY_SEMICOLON,       /* ; */
    LeftBracket = GLFW_KEY_RIGHT_BRACKET, /* [ */
    RightBracket = GLFW_KEY_BACKSLASH,    /* ] */
    AtMark = GLFW_KEY_LEFT_BRACKET,       /* @ */
    Hat = GLFW_KEY_EQUAL,                 /* ^ */
    BackSlash1 = -125,                    /* \ | */ // scancode: 125
    BackSlash2 = -115,                    /* \ _ */ // scancode: 115

    Space = GLFW_KEY_SPACE,
    Enter = GLFW_KEY_ENTER,
    Escape = GLFW_KEY_ESCAPE,
    LeftShift = GLFW_KEY_LEFT_SHIFT,
    RightShift = GLFW_KEY_RIGHT_SHIFT,
    BackSpace = GLFW_KEY_BACKSPACE,
    Delete = GLFW_KEY_DELETE,
    LeftControl = GLFW_KEY_LEFT_CONTROL,
    RightControl = GLFW_KEY_RIGHT_CONTROL,
    Tab = GLFW_KEY_TAB,
    Insert = GLFW_KEY_INSERT
}

enum ButtonState {
    Press = GLFW_PRESS,
    Release = GLFW_RELEASE
}
