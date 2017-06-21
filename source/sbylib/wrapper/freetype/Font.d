module sbylib.wrapper.freetype.Font;

import derelict.freetype.ft;
import sbylib.wrapper.gl;
import sbylib.setting;
import std.string;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Character;

class Font {

    private {
        FT_Face face;
    }
    immutable int size;
    Character[char] characters;
    private FontType fontType;

    this(FT_Face face, int size, FontType fontType) {
        this.face = face;
        this.size = size;
        assert(!FT_Set_Pixel_Sizes(this.face, 0, size), "Failed to set pixel size!");
    }

    void loadChar(char c, FontLoadType loadType) {
        assert (!FT_Load_Char(this.face, c, loadType), "Failed to load character!");
        this.characters[c] = new Character(this.face.glyph, this.face.size.metrics, this.fontType);
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

//    Texture getCharacterTextureFromCode(char chara) {
//        uint charcode = cast(uint)chara;
//        charcode = 65;
//        this.loadChar(charcode, FontLoadType.Default);
//        this.renderGlyph();
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
//        foreach_reverse (i; 0..maxHeight) {
//            foreach (j; 0..advance) {
//                if( (j < bearingX) || (j >= bearingX + width) ||
//                        (i < baseLineHeight-bearingY) ||
//                        (i >= baseLineHeight-bearingY + height) ){
//                    buffer ~= [0,0,0,0];
//                }else{
//                    int row = i - (baseLineHeight - bearingY);
//                    int col = j - bearingX;
//                    auto c = bm.buffer[bm.pitch * row + col];
//                    final switch (fontType) {
//                    case FontType.Mono:
//                        foreach_reverse (bit; 0..8) {
//                            if (((c >> bit) & 1) == 0) {
//                                buffer ~= [0, 0, 0, 0];
//                            } else {
//                                buffer ~= [0xff, 0xff, 0xff, 0xff];
//                            }
//                        }
//                        break;
//                    case FontType.AntiAlias:
//                        buffer ~= [0xff,0xff,0xff,c];
//                        break;
//                    }
//                }
//            }
//        }
//        uint maxWidth;
//        final switch (fontType) {
//        case FontType.Mono:
//            maxWidth = advance*8;
//            break;
//        case FontType.AntiAlias:
//            maxWidth = advance;
//            break;
//        }
//        return new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.RGBA, maxWidth, maxHeight, ImageFormat.RGBA, buffer.ptr);
//    }
}
