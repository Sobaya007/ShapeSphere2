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

class Label {

    alias entity this;

    enum Strategy {Center, Left, Right}

    Entity entity;
    private vec4 mColor;
    private vec4 backColor;
    private Font font;
    private float wrapWidth;
    float size; //1 letter height
    private float mWidth, mHeight;
    private dstring text;
    private dstring[] textByRow;
    private Sentence[] sentences;
    private Strategy strategy;

    this(Font font, float size, float wrapWidth, Strategy strategy, vec4 color, vec4 backColor, dstring text) {
        this.font = font;
        this.size = size;
        this.wrapWidth = wrapWidth;
        this.strategy = strategy;
        this.mColor = color;
        this.backColor = backColor;
        this.text = text;
        this.entity = new Entity;
        this.entity.name = "Label";
        this.mWidth = this.mHeight = 0;
        this.renderText(text);
    }

    vec4 color() {
        return this.mColor;
    }

    vec4 color(vec4 newColor) {
        this.mColor = newColor;
        import std.algorithm;
        this.sentences.each!(s => s.color = color);
        return newColor;
    }

    float width() {
        return this.mWidth;
    }

    float height() {
        return this.mHeight;
    }

    void renderText(string text) {
        import std.conv;
        renderText(text.to!dstring);
    }

    void renderText(dstring text) {
        if (text != text) return;
        this.text = text;
        this.mWidth = this.mHeight = 0;
        this.lineUp();
        import std.conv;
        this.name = "Label '"~text.to!string~"'";
    }

    float left(float value) {
        this.pos.x = value + this.mWidth/2;
        return value;
    }

    float right(float value) {
        this.pos.x = value - this.mWidth/2;
        return value;
    }

    float top(float value) {
        this.pos.y = value - this.mHeight/2;
        return value;
    }

    float bottom(float value) {
        this.pos.y = value + this.mHeight/2;
        return value;
    }

    private void lineUp() {
        import std.array, std.algorithm, std.range;
        Font.LetterInfo[][] rows;
        auto text = this.text;
        auto wrapWidth = this.wrapWidth * font.size / this.size;
        auto pen = 0;
        this.textByRow = null;
        while (!text.empty) {
            pen = 0;
            Font.LetterInfo[] infos;
            dstring rowString;
            while (!text.empty) {
                if (text.front == '\n') {
                    rowString ~= '\n';
                    text.popFront;
                    break;
                }
                auto info = font.getLetterInfo(text.front);
                if (pen + info.advance > wrapWidth) break;
                infos ~= info;
                rowString ~= text.front;
                text = text[1..$];
                pen += info.advance;
            }
            rows ~= infos;
            textByRow ~= rowString;
        }
        this.mWidth = rows.map!(row => row.map!(i => i.advance).sum).fold!(max)(0L) * this.size / font.size;
        this.mHeight = rows.length * this.size;
        if (sentences.length < rows.length) {
            auto newSentences = iota(rows.length-sentences.length).map!(_ => new Sentence).array;
            sentences ~= newSentences;
        }
        this.entity.clearChildren();
        foreach (s; sentences[0..rows.length]) {
            this.entity.addChild(s);
        }
        zip(rows, sentences).each!(t => t[1].setBuffer(t[0], this.size));
        final switch (this.strategy) {
            case Strategy.Left:
                this.sentences.each!(s => s.pos.x = (s.width - this.mWidth)/2);
                break;
            case Strategy.Center:
                this.sentences.each!(s => s.pos.x = 0);
                break;
            case Strategy.Right:
                this.sentences.each!(s => s.pos.x = (this.mWidth - s.width)/2);
                break;
        }
        this.sentences.enumerate.each!(s => s.value.pos.y = s.index * -this.size + this.mHeight/2 - this.size / 2);
        this.sentences.each!(s => s.color = color);
        this.sentences.each!(s => s.backColor = backColor);
    }

    alias entity this;
}
