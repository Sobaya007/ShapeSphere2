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
    int _maximumTextLength = 1000; // 最大文字数

    Maybe!Clipboard _clipboard = None!Clipboard;

    // [_leftIndex, _rightIndex] は文字列の選択範囲
    // _selectedIndex は選択範囲の起点
    int _leftIndex = 0;
    int _rightIndex = 0;
    int _selectedIndex = 0;

    LabelComponent _label;

    Entity _coverEntity;
    int _coverAnimationFrameCount = 0;
    const int _coverAnimationDuration = 80;

    TextAreaComponentMaterial material;

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
        auto entity = makeEntity(geom, new TextAreaComponentMaterial);

        this.material = entity.mat;

        this.material.borderColor = _borderColor;
        this.material.backgroundColor = _backgroundColor;
        this.material.borderSize = _borderSize;
        this.material.size = vec2(width, height);

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

    void setClipboard(Clipboard clipboard) {
        _clipboard = Just(clipboard);
    }

    void setText(dstring text) {
        _text = text;
        refreshText();
        goRightEnd(false);
    }

    void setMaximumTextLength(int length) {
        _maximumTextLength = length;
        refreshText();
    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        updateCover();
        if (activeControllable.isJust && activeControllable.get is this) {
            _coverAnimationFrameCount++;
        }
    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {
        convChar(keyButton, shiftPressed, controlPressed).apply!(
            c => insertText(c)
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
        if (keyButton == KeyButton.Up) {
            goLeftEnd(shiftPressed);
        }
        if (keyButton == KeyButton.Down) {
            goRightEnd(shiftPressed);
        }
        if (keyButton == KeyButton.KeyA && controlPressed) {
            selectAll();
        }
        if (keyButton == KeyButton.KeyC && controlPressed) {
            copyText();
        }
        if (keyButton == KeyButton.KeyV && controlPressed) {
            pasteText();
        }
        if (keyButton == KeyButton.KeyX && controlPressed) {
            copyText();
            deleteSelectedRange();
        }

    }

private:
    // 選択中の範囲があるか？
    bool hasSelectedRange() {
        return _leftIndex < _rightIndex;
    }

    Maybe!dstring getSelectedText() {
        return hasSelectedRange() ? Just(_text[_leftIndex.._rightIndex]) : None!dstring;
    }

    void incIndex(bool shiftPressed) {
        if (_leftIndex > _selectedIndex) {
            _leftIndex = min(_text.length, _leftIndex + 1);
        } else {
            _rightIndex = min(_text.length, _rightIndex + 1);
        }
        if (!shiftPressed) {
            _leftIndex = _selectedIndex = _rightIndex;
        }
        refreshCover();
    }

    void decIndex(bool shiftPressed) {
        if (_selectedIndex < _rightIndex) {
            _rightIndex = max(0, _rightIndex - 1);
        } else {
            _leftIndex = max(0, _leftIndex - 1);
        }
        if (!shiftPressed) {
            _rightIndex = _selectedIndex = _leftIndex;
        }
        refreshCover();
    }

    void goRightEnd(bool shiftPressed) {
        if (shiftPressed) {
            _rightIndex = cast(int)_text.length;
        } else {
            _leftIndex = _selectedIndex = _rightIndex = cast(int)_text.length;
        }
        refreshCover();
    }

    void goLeftEnd(bool shiftPressed) {
        if (shiftPressed) {
            _leftIndex = 0;
        } else {
            _rightIndex = _selectedIndex = _leftIndex = 0;
        }
        refreshCover();
    }

    // setClipboardをしていないと何もしない
    void copyText() {
        _clipboard.apply!(
            c => getSelectedText().apply!(
                (selectedText) {
                    c.set(selectedText);
                }
            )
        );
    }

    // setClipboardをしていないと何もしない
    void pasteText() {
        _clipboard.apply!(
            (c) {
                deleteSelectedRange();
                insertText(c.get());
                refreshText();
            }
        );
    }

    void selectAll() {
        _selectedIndex = _leftIndex = 0;
        _rightIndex = cast(int)_text.length;
        refreshCover();
    }

    void insertText(dchar c) {
        deleteSelectedRange();
        _text.insertInPlace(_leftIndex, c);
        incIndex(false);
        refreshText();
    }

    void insertText(dstring str) {
        deleteSelectedRange();
        _text.insertInPlace(_leftIndex, str);
        _leftIndex = _selectedIndex = _rightIndex = cast(int)(_rightIndex + str.length);
        refreshText();
    }

    // 選択中の文字列を削除、何も選択していない場合は左1文字を削除
    void deleteLeft() {
        if (!hasSelectedRange()) {
            decIndex(true);
        }
        deleteSelectedRange();
    }

    // 選択中の文字列を削除、何も選択していない場合は右1文字を削除
    void deleteRight() {
        if (!hasSelectedRange()) {
            incIndex(true);
        }
        deleteSelectedRange();
    }

    // 選択範囲の文字列を削除する
    void deleteSelectedRange() {
        _text = _text[0.._leftIndex] ~ _text[_rightIndex..$];
        _selectedIndex = _rightIndex = _leftIndex;
        refreshText();
    }

    // 選択範囲を解除する
    void clearSelectedRange() {
        _rightIndex = _leftIndex = _selectedIndex;
        refreshCover();
    }

    void refreshText() {
        _text = _text[0..min($, _maximumTextLength)];
        _leftIndex     = min(_leftIndex, _maximumTextLength);
        _selectedIndex = min(_selectedIndex, _maximumTextLength);
        _rightIndex    = min(_rightIndex, _maximumTextLength);
        _label.setText(_text);
        refreshCover();
    }

    void refreshCover() {
        _coverEntity.clearChildren();
        auto letters = _label.getLabel.getLetters;
        foreach(i, letter; letters) {
            if (i < _leftIndex) continue;
            if (i >= _rightIndex) continue;

            auto geom = letter.getEntity.geom;
            auto entity = makeEntity(geom, new TextAreaComponentCoverMaterial);
            entity.color = _coverColor;
            entity.opacity = getCoverOpacity();
            entity.pos = letter.getEntity.pos.get();
            _coverEntity.addChild(entity);
        }
        {
            // selectIndexの位置に関するcoverの設置
            float x = letters
                .take(_selectedIndex)
                .map!"a.getEntity.obj.pos.x + a.width/2"
                .fold!"b"(0f);
            float y = letters
                .take(_selectedIndex)
                .map!"cast(float)a.getEntity.obj.pos.y"
                .fold!"b"(-_label.getFontSize/2);
            auto geom = Rect.create(2, _label.getFontSize, Rect.OriginX.Left, Rect.OriginY.Center);
            auto entity = makeEntity(geom, new TextAreaComponentCoverMaterial);
            entity.color = _coverColor;
            entity.opacity = getCoverOpacity();
            entity.pos.x = x;
            entity.pos.y = y;
            _coverEntity.addChild(entity);
        }
    }

    void updateCover() {
        _coverEntity.traverse((Entity entity) {
            (cast(TextAreaComponentCoverMaterial)entity.mesh.get().mat).opacity = getCoverOpacity();
        });
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
        import std.format;
        string msg = format!"[leftIndex: %d, selectedIndex: %d, rightIndex: %d]"(_leftIndex, _selectedIndex, _rightIndex);
        assert(0 <= _leftIndex, msg);
        assert(_leftIndex <= _selectedIndex, msg);
        assert(_selectedIndex <= _rightIndex, msg);
        assert(_rightIndex <= _text.length, msg);
    }

}
