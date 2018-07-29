module sbylib.character.Label;
    
public import sbylib.character.ColoredString;

import sbylib.entity.Entity;

class Label : Entity {

    import sbylib.character.Sentence;
    import sbylib.math.Vector;
    import sbylib.wrapper.freetype.Font;

    enum Strategy {Center, Left, Right}

    struct Char {
        Font.LetterInfo info;
        vec4 color;
    }

    private Font font;
    private float wrapWidth;
    float size; //1 letter height
    private float mWidth, mHeight;
    private ColoredString mText;
    private ColoredString[] mTextByRow;
    private Sentence[] sentences;
    private Strategy strategy;
    private Entity sentenceContainer; // for separate for other child

    this(Font font, float size, float wrapWidth, Strategy strategy, ColoredString mText) {
        this.sentenceContainer = new Entity;
        this.addChild(sentenceContainer);
        this.font = font;
        this.size = size;
        this.wrapWidth = wrapWidth;
        this.strategy = strategy;
        this.mText = mText;
        this.name = "Label";
        this.mWidth = this.mHeight = 0;
        this.renderText(mText);
    }

    vec4 color(vec4 newColor) {
        import std.algorithm;
        this.sentences.each!(s => s.color = newColor);
        return newColor;
    }

    float alpha(float a) {
        import std.algorithm;
        this.sentences.each!(s => s.alpha = a);
        return a;
    }

    float width() {
        return this.mWidth;
    }

    float height() {
        return this.mHeight;
    }

    auto text() {
        return this.mText;
    }

    void renderText(ColoredString mText) {
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
        Char[][] rows;
        auto mText = this.mText;
        auto wrapWidth = this.wrapWidth * font.size / this.size;
        auto pen = 0;
        this.mTextByRow = null;
        while (!mText.empty) {
            pen = 0;
            Char[] row;
            ColoredString rowString;
            while (!mText.empty) {
                scope(exit) mText.popFront;
                if (mText.front.c == '\n') {
                    rowString ~= '\n';
                    break;
                }
                auto info = font.getLetterInfo(mText.front.c);
                if (pen + info.advance > wrapWidth) break;
                row ~= Char(info, mText.front.color);
                rowString ~= mText.front;
                pen += info.advance;
            }
            rows ~= row;
            mTextByRow ~= rowString;
        }
        this.mWidth = rows.map!(row => row.map!(c => c.info.advance).sum).fold!(max)(0L) * this.size / font.size;
        this.mHeight = rows.length * this.size;
        if (sentences.length < rows.length) {
            auto newSentences = iota(rows.length-sentences.length).map!(_ => new Sentence).array;
            sentences ~= newSentences;
        }
        sentenceContainer.clearChildren();
        foreach (s; sentences[0..rows.length]) {
            sentenceContainer.addChild(s);
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
    }
}
