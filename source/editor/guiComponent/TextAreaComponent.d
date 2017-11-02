module editor.guiComponent.TextAreaComponent;

import sbylib;
import editor.guiComponent;

import std.uni;
import std.array;
import std.range;
import std.algorithm;
import std.math;

class TextAreaComponent : AGuiComponent {

private:
    float _width;
    float _height;

    dstring _text = "";

    // [_leftIndex, _rightIndex] は文字列の選択範囲
    // _selectIndex は選択範囲の起点
    int _leftIndex = 0;
    int _rightIndex = 0;
    int _selectIndex = 0;

    LabelComponent _label;

    Entity _coverEntity;
    int _coverAnimationFrameCount = 0;
    const int _coverAnimationDuration = 80;

    vec4 _borderColor = vec4(0.5, 0.5, 0.5, 1);
    vec4 _backgroundColor = vec4(0.9, 0.9, 0.9, 1.0);
    float _borderSize = 10;
    vec4 _textColor = vec4(0, 0, 0, 1);
    vec4 _coverColor = vec4(0.1, 0.1, 0.1, 0.6);

public:
    this(float width, float height, float textSize) {
        _width = width;
        _height = height;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, TextAreaComponentMaterial)(geom);

        entity.getMesh.mat.borderColor = _borderColor;
        entity.getMesh.mat.backgroundColor = _backgroundColor;
        entity.getMesh.mat.borderSize = _borderSize;
        entity.getMesh.mat.size = vec2(width, height);

        _label = new LabelComponent(_text, textSize, _textColor, Label.OriginX.Left, Label.OriginY.Top, width - _borderSize*2);
        _label.x = _borderSize;
        _label.y = -_borderSize;
        _label.zIndex = 1;

        entity.addChild(_label.entity);

        _coverEntity = new Entity;
        _coverEntity.obj.pos.x = _borderSize;
        _coverEntity.obj.pos.y = -_borderSize;
        _coverEntity.obj.pos.z = 1;
        entity.addChild(_coverEntity);

        super(entity);

        refreshCover();
    }

    override float width() {
        return _width;
    }

    override float height() {
        return _height;
    }

    override void update(Mouse2D mouse) {
        updateCover();
    }
    override void activeUpdate(Mouse2D mouse) {
        _coverAnimationFrameCount++;
    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {
        convChar(keyButton, shiftPressed, controlPressed).apply!(
            c => insertChar(c)
        );
        if (keyButton == KeyButton.BackSpace) {
            deleteLeft();
        }
        if (keyButton == KeyButton.Delete) {
            deleteRight();
        }
        if (keyButton == KeyButton.Left) {
            decIndex(shiftPressed);
        }
        if (keyButton == KeyButton.Right) {
            incIndex(shiftPressed);
        }
        if (keyButton == KeyButton.KeyA && controlPressed) {
            selectAll();
        }
    }

private:
    void incIndex(bool shiftPressed) {
        if (_leftIndex < _selectIndex) {
            _leftIndex = min(_text.length, _leftIndex + 1);
        } else {
            _rightIndex = min(_text.length, _rightIndex + 1);
        }
        if (!shiftPressed) {
            _selectIndex = _leftIndex = _rightIndex;
        }
        refreshCover();
    }

    void decIndex(bool shiftPressed) {
        if (_selectIndex < _rightIndex) {
            _rightIndex = max(0, _rightIndex - 1);
        } else {
            _leftIndex = max(0, _leftIndex - 1);
        }
        if (!shiftPressed) {
            _selectIndex = _rightIndex = _leftIndex;
        }
        refreshCover();
    }

    void selectAll() {
        _selectIndex = _leftIndex = 0;
        _rightIndex = _text.length;
        refreshCover();
    }

    void insertChar(dchar c) {
        deleteInterval();
        _text.insertInPlace(_leftIndex, c);
        incIndex(false);
        refreshText();
    }

    void deleteLeft() {
        if (_leftIndex == _rightIndex) {
            decIndex(true);
        }
        deleteInterval();
    }

    void deleteRight() {
        if (_leftIndex == _rightIndex) {
            incIndex(true);
        }
        deleteInterval();
    }

    // 選択範囲の文字列を削除する
    void deleteInterval() {
        _text = _text[0.._leftIndex] ~ _text[_rightIndex..$];
        _selectIndex = _rightIndex = _leftIndex;
        refreshText();
    }

    void refreshText() {
        _label.setText(_text);
        refreshCover();
    }

    void refreshCover() {
        _coverEntity.clearChildren();
        auto letters = _label.getLabel.getLetters;
        foreach(i, letter; letters) {
            if (i < _leftIndex) continue;
            if (i >= _rightIndex) continue;

            auto geom = letter.getEntity.getMesh.geom;
            auto entity = new EntityTemp!(GeometryRect, TextAreaComponentCoverMaterial)(geom);
            entity.getMesh.mat.color = _coverColor;
            entity.getMesh.mat.opacity = getCoverOpacity();
            entity.obj.pos = letter.getEntity.obj.pos;
            _coverEntity.addChild(entity);
        }
        {
            // selectIndexの位置に関するcoverの設置
            float x = letters
                .take(_selectIndex)
                .map!"a.getEntity.obj.pos.x + a.width/2"
                .fold!"b"(0f);
            float y = letters
                .take(_selectIndex)
                .map!"a.getEntity.obj.pos.y"
                .fold!"b"(-_label.getFontSize/2);
            auto geom = Rect.create(2, _label.getFontSize, Rect.OriginX.Left, Rect.OriginY.Center);
            auto entity = new EntityTemp!(GeometryRect, TextAreaComponentCoverMaterial)(geom);
            entity.getMesh.mat.color = _coverColor;
            entity.getMesh.mat.opacity = getCoverOpacity();
            entity.obj.pos.x = x;
            entity.obj.pos.y = y;
            _coverEntity.addChild(entity);
        }
    }

    void updateCover() {
        foreach(entity; _coverEntity.getChildren()) {
            (cast(TextAreaComponentCoverMaterial)entity.getMesh.mat).opacity = getCoverOpacity();
        }
    }

    float getCoverOpacity() {
        float t = _coverAnimationFrameCount % _coverAnimationDuration / cast(float)_coverAnimationDuration;
        t = sin(2*PI * t) * 0.5 + 0.5; // [-1, 1] -> [0, 1]
        // t = 1 - t*t;
        t = t*0.7 + 0.3; // [0, 1] -> [0.3, 1]
        return t;
    }

    // KeyButton -> Maybe!dchar
    Maybe!dchar convChar(KeyButton keyButton, bool shiftPressed, bool controlPressed) {
        Maybe!dchar ch = None!dchar;
        switch(keyButton) {
            // alphabets
            case KeyButton.KeyA: ch = Just(dchar('A')); break;
            case KeyButton.KeyB: ch = Just(dchar('B')); break;
            case KeyButton.KeyC: ch = Just(dchar('C')); break;
            case KeyButton.KeyD: ch = Just(dchar('D')); break;
            case KeyButton.KeyE: ch = Just(dchar('E')); break;
            case KeyButton.KeyF: ch = Just(dchar('F')); break;
            case KeyButton.KeyG: ch = Just(dchar('G')); break;
            case KeyButton.KeyH: ch = Just(dchar('H')); break;
            case KeyButton.KeyI: ch = Just(dchar('I')); break;
            case KeyButton.KeyJ: ch = Just(dchar('J')); break;
            case KeyButton.KeyK: ch = Just(dchar('K')); break;
            case KeyButton.KeyL: ch = Just(dchar('L')); break;
            case KeyButton.KeyM: ch = Just(dchar('M')); break;
            case KeyButton.KeyN: ch = Just(dchar('N')); break;
            case KeyButton.KeyO: ch = Just(dchar('O')); break;
            case KeyButton.KeyP: ch = Just(dchar('P')); break;
            case KeyButton.KeyQ: ch = Just(dchar('Q')); break;
            case KeyButton.KeyR: ch = Just(dchar('R')); break;
            case KeyButton.KeyS: ch = Just(dchar('S')); break;
            case KeyButton.KeyT: ch = Just(dchar('T')); break;
            case KeyButton.KeyU: ch = Just(dchar('U')); break;
            case KeyButton.KeyV: ch = Just(dchar('V')); break;
            case KeyButton.KeyW: ch = Just(dchar('W')); break;
            case KeyButton.KeyX: ch = Just(dchar('X')); break;
            case KeyButton.KeyY: ch = Just(dchar('Y')); break;
            case KeyButton.KeyZ: ch = Just(dchar('Z')); break;

            // numbers
            case KeyButton.Key0: ch = shiftPressed ? None!dchar : Just(dchar('0')); break;
            case KeyButton.Key1: ch = Just(dchar(shiftPressed ? '!' : '1')); break;
            case KeyButton.Key2: ch = Just(dchar(shiftPressed ? '"' : '2')); break;
            case KeyButton.Key3: ch = Just(dchar(shiftPressed ? '#' : '3')); break;
            case KeyButton.Key4: ch = Just(dchar(shiftPressed ? '$' : '4')); break;
            case KeyButton.Key5: ch = Just(dchar(shiftPressed ? '%' : '5')); break;
            case KeyButton.Key6: ch = Just(dchar(shiftPressed ? '&' : '6')); break;
            case KeyButton.Key7: ch = Just(dchar(shiftPressed ? '\'' : '7')); break;
            case KeyButton.Key8: ch = Just(dchar(shiftPressed ? '(' : '8')); break;
            case KeyButton.Key9: ch = Just(dchar(shiftPressed ? ')' : '9')); break;

            // special characters
            case KeyButton.Space:        ch = Just(dchar(' ')); break;
            case KeyButton.Comma:        ch = Just(dchar(shiftPressed ? '<' : ',')); break;
            case.KeyButton.Minus:        ch = Just(dchar(shiftPressed ? '=' : '-')); break;
            case.KeyButton.Period:       ch = Just(dchar(shiftPressed ? '>' : '.')); break;
            case.KeyButton.Slash:        ch = Just(dchar(shiftPressed ? '?' : '/')); break;
            case.KeyButton.Semicolon:    ch = Just(dchar(shiftPressed ? '+' : ';')); break;
            case.KeyButton.LeftBracket:  ch = Just(dchar(shiftPressed ? '{' : '[')); break;
            case.KeyButton.RightBracket: ch = Just(dchar(shiftPressed ? '}' : ']')); break;
            case.KeyButton.AtMark:       ch = Just(dchar(shiftPressed ? '`' : '@')); break;
            case.KeyButton.Hat:          ch = Just(dchar(shiftPressed ? '~' : '^')); break;
            case.KeyButton.BackSlash1:   ch = Just(dchar(shiftPressed ? '|' : '\\')); break;
            case.KeyButton.BackSlash2:   ch = Just(dchar(shiftPressed ? '_' : '\\')); break;

            default: {
                // do nothing
            }
        }

        if (shiftPressed) {
            ch = ch.fmap!toUpper;
        } else {
            ch = ch.fmap!toLower;
        }

        if (controlPressed) {
            ch = None!dchar;
        }

        return ch;
    }

    invariant {
        assert(0 <= _leftIndex);
        assert(_leftIndex <= _selectIndex);
        assert(_selectIndex <= _rightIndex);
        assert(_rightIndex <= _text.length);
    }

}
