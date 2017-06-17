module sbylib.wrapper.freetype.Font;

import derelict.freetype.ft;
import sbylib.wrapper.gl;
import sbylib.setting;
import std.string;

enum FontType {
    Mono = FT_RENDER_MODE_MONO,
    AntiAlias = FT_RENDER_MODE_NORMAL
}

class Font {

    private {
        FT_Face face;
        immutable FontType fontType;
        Texture[int] textures;
        immutable int maxWidthPerChar;
        immutable int baseLineHeight;
        immutable int maxHeight;
    }
    immutable int size;

    this(FT_Face face, FontType fontType, int size) {
        this.face = face;
        this.fontType = fontType;
        this.size = size;
        assert(!FT_Set_Pixel_Sizes(face, size, size), "Failed to set pixel size!");

        FT_Size_Metrics sz = face.size.metrics;
        maxWidthPerChar = cast(int)sz.max_advance / 64;
        baseLineHeight = cast(int)sz.ascender / 64;
        maxHeight = cast(int)(sz.ascender - sz.descender) / 64;
    }

//    Texture renderText(wstring text, float font_size = this.size) {
//        int len = cast(int)text.length;
//        int texWidth = cast(int)(cast(float)maxWidthPerChar*len*font_size/size);
//        int texHeight = cast(int)(cast(float)maxHeight*font_size/size);
//        Texture texture = new Texture(texWidth,texHeight,ImageType.RGBA);
//        static FrameBuffer fbo;
//        if (fbo is null) fbo = new FrameBuffer;
//        fbo.attachTextureAsColor(texture);
//        fbo.write(texture.width, texture.height, {
//            int x = 0;
//            foreach (c; text) {
//                Texture charaTex = getCharacterTexture(c);
//                uint width = cast(uint)(cast(float)charaTex.width / size * font_size);
//                uint height = cast(uint)(cast(float)charaTex.height / size * font_size);
//                //writeln("(poo) width * height = " ~ "(" ~ to!string(width) ~ "," ~ to!string(font_size) ~ ")" );
//                //writeln("(tex) width * height = " ~ "(" ~ to!string(charaTex.width) ~ "," ~ to!string(charaTex.height) ~ ")" );
//                /*
//        drawImage(x+width/2, height/2, width, height, charaTex);
//*/
//                x += width;
//            }
//        });
//        return texture;
//    }

//    Texture getCharacterTexture(T)(inout T character) if (is (T == char) || is (T == wchar) || is (T == dchar)) {
//        int charcode = cast(int)character;
//        auto result = charcode in textures;
//        if (result) return *result;
//
//        return getCharacterTextureFromCode(charcode);
//    }
//
//    private Texture getCharacterTextureFromCode(int charcode) {
//
//        auto err = FT_Load_Char(face, charcode, 0);
//        if (err) assert (false, "Failed to load character!");
//
//        err = FT_Render_Glyph(face.glyph, fontType);
//        if (err) assert (false, "Failed to render glyph!!");
//
//        FT_Bitmap bm = face.glyph.bitmap;
//
//        /*
//Note:FT_Bitmapについて:
//rows:縦に何ピクセルあるか
//width:横に何ピクセルあるか
//pitch:横1列で何Byteあるか
//
//buffer:
//MONOの場合:	1ピクセルあたり1bit。ビットが立っていれば塗って、そうでなければ塗らない
//NORMALの場合: 1ピクセルあたり1Byte。0~0xffでそのピクセルのα値を表す。
//     */
//
//        // ベースラインを考慮してTexture込めるようにします
//        // FT_Pos := signed long です
//
//        FT_Glyph_Metrics met = face.glyph.metrics;
//        // FT_Pos met.width
//        // FT_Pos met.height
//        // FT_Pos met.horiBearingX
//        // FT_Pos met.horiBearingY
//        // FT_Pos met.horiAdvance
//
//        // buffer width := met.advance
//        // buffer height:= maxHeight
//
//        uint advance = cast(uint)met.horiAdvance/64;
//        uint bearingX = cast(uint)met.horiBearingX/64;
//        uint width = cast(uint)met.width/64;
//        uint bearingY = cast(uint)met.horiBearingY/64;
//        uint height = cast(uint)met.height/64;
//
//        ubyte[] buffer;
//        final switch (fontType) {
//        case FontType.Mono:
//            foreach_reverse (i; 0..maxHeight) {
//                foreach (j; 0..advance) {
//                    if( (j < bearingX) || (j >= bearingX + width) ||
//                            (i < baseLineHeight-bearingY) ||
//                            (i >= baseLineHeight-bearingY + height) ){
//                        buffer ~= [0,0,0,0];
//                    }else{
//                        int row = i - (baseLineHeight - bearingY);
//                        int col = j - bearingX;
//                        auto c = bm.buffer[bm.pitch * row + col];
//                        foreach_reverse (bit; 0..8) {
//                            if (((c >> bit) & 1) == 0) {
//                                buffer ~= [0, 0, 0, 0];
//                            } else {
//                                buffer ~= [0xff, 0xff, 0xff, 0xff];
//                            }
//                        }
//                    }
//                }
//            }
//            return textures[charcode] = new Texture(buffer.ptr, advance*8, maxHeight);
//        case FontType.AntiAlias:
//            foreach_reverse (i; 0..maxHeight) {
//                foreach (j; 0..advance) {
//                    if( (j < bearingX) || (j >= bearingX + width) ||
//                            (i < baseLineHeight-bearingY) ||
//                            (i >= baseLineHeight-bearingY + height) ){
//                        buffer ~= [0,0,0,0];
//                    }else{
//                        int row = i - (baseLineHeight - bearingY);
//                        int col = j - bearingX;
//                        auto c = bm.buffer[bm.pitch * row + col];
//                        buffer ~= [0xff,0xff,0xff,c];
//                    }
//                }
//            }
//            return textures[charcode] = new Texture(buffer.ptr, advance, maxHeight);
//        }
//    }

}
