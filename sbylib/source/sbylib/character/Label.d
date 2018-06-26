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

class Label : Entity {

    alias obj this;

    enum Strategy {Center, Left, Right}

    private vec4 mColor;
    private vec4 backColor;
    private Font font;
    private float wrapWidth;
    float size; //1 letter height
    private float mWidth, mHeight;
    private dstring mText;
    private dstring[] mTextByRow;
    private Sentence[] sentences;
    private Strategy strategy;

    this(Font font, float size, float wrapWidth, Strategy strategy, vec4 color, vec4 backColor, dstring mText) {
        this.font = font;
        this.size = size;
        this.wrapWidth = wrapWidth;
        this.strategy = strategy;
        this.mColor = color;
        this.backColor = backColor;
        this.mText = mText;
        this.name = "Label";
        this.mWidth = this.mHeight = 0;
        this.renderText(mText);
        this.setUserData("Label", this);
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

    dstring text() {
        return this.mText;
    }

    void renderText(string mText) {
        import std.conv;
        renderText(mText.to!dstring);
    }

    void renderText(dstring mText) {
        if (mText != mText) return;
        this.mText = mText;
        this.mWidth = this.mHeight = 0;
        this.lineUp();
        import std.conv;
        this.name = "Label '"~mText.to!string~"'";
    }

    import sbylib.utils.Functions;
    mixin ImplPositionSetter!(mWidth, mHeight);

    private void lineUp() {
        import std.array, std.algorithm, std.range;
        Font.LetterInfo[][] rows;
        auto mText = this.mText;
        auto wrapWidth = this.wrapWidth * font.size / this.size;
        auto pen = 0;
        this.mTextByRow = null;
        while (!mText.empty) {
            pen = 0;
            Font.LetterInfo[] infos;
            dstring rowString;
            while (!mText.empty) {
                if (mText.front == '\n') {
                    rowString ~= '\n';
                    mText.popFront;
                    break;
                }
                auto info = font.getLetterInfo(mText.front);
                if (pen + info.advance > wrapWidth) break;
                infos ~= info;
                rowString ~= mText.front;
                mText = mText[1..$];
                pen += info.advance;
            }
            rows ~= infos;
            mTextByRow ~= rowString;
        }
        this.mWidth = rows.map!(row => row.map!(i => i.advance).sum).fold!(max)(0L) * this.size / font.size;
        this.mHeight = rows.length * this.size;
        if (sentences.length < rows.length) {
            auto newSentences = iota(rows.length-sentences.length).map!(_ => new Sentence).array;
            sentences ~= newSentences;
        }
        this.clearChildren();
        foreach (s; sentences[0..rows.length]) {
            this.addChild(s);
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
}
