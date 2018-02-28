module sbylib.character.Label;

import sbylib.geometry.geometry2d.Rect;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Font;
import sbylib.entity.Mesh;
import sbylib.material.TextMaterial;
import sbylib.entity.Object3D;
import sbylib.math.Vector;
import sbylib.character.Sentence;
import std.typecons;
import std.math;

struct LetterInfo {
    Font.LetterInfo info;
    int ox;
    alias info this;
}

class Label {

    alias entity this;

    enum Strategy {Center, Left, Right}

    Entity entity;
    private vec4 _color;
    private vec4 backColor;
    private Font font;
    private float wrapWidth;
    private float size; //1 letter height
    private float width, height;
    private dstring text;
    private Sentence[] sentences;
    private Strategy strategy;

    this(Font font, float size, float wrapWidth, Strategy strategy, vec4 color, vec4 backColor, dstring text) {
        this.font = font;
        this.size = size;
        this.wrapWidth = wrapWidth;
        this.strategy = strategy;
        this._color = color;
        this.backColor = backColor;
        this.text = text;
        this.entity = new Entity;
        this.renderText(text);
    }

    vec4 color() {
        return this._color;
    }

    vec4 color(vec4 newColor) {
        this._color = newColor;
        import std.algorithm;
        this.sentences.each!(s => s.color = color);
        return newColor;
    }

    float getWidth() {
        return this.width;
    }

    float getHeight() {
        return this.height;
    }

    void renderText(string text) {
        import std.conv;
        renderText(text.to!dstring);
    }

    void renderText(dstring text) {
        if (text != text) return;
        this.text = text;
        this.lineUp();
    }

    float left(float value) {
        this.pos.x = value + this.width/2;
        return value;
    }

    float right(float value) {
        this.pos.x = value - this.width/2;
        return value;
    }

    float top(float value) {
        this.pos.y = value - this.height/2;
        return value;
    }

    float bottom(float value) {
        this.pos.y = value + this.height/2;
        return value;
    }

    private void lineUp() {
        import std.array, std.algorithm, std.range;
        if (this.text.empty) return;
        import sbylib.wrapper.freetype.StringTexture;
        LetterInfo[][] rows;
        auto text = this.text;
        auto wrapWidth = this.wrapWidth / this.size;
        this.width = 0;
        while (!text.empty) {
            LetterInfo[] infos;
            while (!text.empty) {
                auto info = font.getLetterInfo(text.front);
                if (this.width + info.maxWidth > wrapWidth*font.size) break;
                infos ~= LetterInfo(info, cast(int)this.width);
                text = text[1..$];
                this.width += info.maxWidth;
            }
            rows ~= infos;
        }
        this.width *= this.size / font.size;
        this.height = rows.length * this.size;
        if (sentences.length < rows.length) {
            auto newSentences = iota(rows.length-sentences.length).map!(_ => new Sentence).array;
            sentences ~= newSentences;
            newSentences.each!(s => this.entity.addChild(s));
        }
        sentences.each!(s => s.visible = true);
        if (sentences.length > rows.length)
            sentences[rows.length..$].each!(s => s.visible = false);
        zip(rows, sentences).each!(t => t[1].setBuffer(t[0], this.size));
        final switch (this.strategy) {
            case Strategy.Left:
                this.sentences.each!(s => s.pos.x = (s.width - this.width)/2);
                break;
            case Strategy.Center:
                this.sentences.each!(s => s.pos.x = 0);
                break;
            case Strategy.Right:
                this.sentences.each!(s => s.pos.x = (this.width - s.width)/2);
                break;
        }
        this.sentences.enumerate.each!(s => s.value.pos.y = this.height/2 - s.index * this.size);
        this.sentences.each!(s => s.color = color);
        this.sentences.each!(s => s.backColor = backColor);
    }

    alias entity this;
}
