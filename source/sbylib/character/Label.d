module sbylib.character.Label;

import sbylib;

// 担当 : _n_ari

// 文字列を描画するラベルを生成
// 左上基準で描画するようにした

// 実は font.renderText で TextureObject を返しているだけなので
// Label クラス使わなくてもいいよ(適当)
//それマジ？！

class Label {

    TextureObject tex;
    Font font;
    float size;
    wstring str;
    int w, h;

    this(Font font, wstring s = "Hello, World!", float size = -1) {
        setFont(font);
        setString(s,size);
    }

    void setFont(Font font, float size = -1){
        this.font = font;
        this.size = size;
        if(size<0) this.size = font.size;
    }

    void setString(wstring s, float size = -1){
        if(size<0)size = this.size;
        if(font is null)font = this.font;
        this.str = s;
        this.tex = font.renderText(s,size);
        this.w = this.tex.width;
        this.h = this.tex.height;
    }

    // 左下(0,0)です
    void draw(float x = 0f,float y = 0f,vec4 color=white) {
        float cx,cy;
        cx = x + w/2;
        cy = y + h/2;
        //// 可視化
        //drawRect(cx,cy,w,h,vec4(1f,0f,0f,0.5f));
        //drawImageWithColor(cx,cy,w,h,tex,color);
    }
}
