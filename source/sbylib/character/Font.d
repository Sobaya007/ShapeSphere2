module sbylib.character.Font;

import derelict.freetype.ft;
import sbylib.gl;
import std.string;

class Font {
    private static FT_Library library;

    static this() {
        DerelictFT.load("../dll/freetype.dll");
        auto err = FT_Init_FreeType(&library);
        if (err) {
            assert(false, "Failed to init freetype!");
        }
    }

    enum LoadType {Mono = FT_RENDER_MODE_MONO, AntiAlias = FT_RENDER_MODE_NORMAL}

    private {
        FT_Face face;
        LoadType loadType;
        TextureObject[int] textures;
    }
    immutable int size;
    immutable int maxWidthPerChar;
    immutable int baseLineHeight;
    immutable int maxHeight;

    this(string filePath, LoadType loadType, int size) {
        this.size = size;
        this.loadType = loadType;

        auto err = FT_New_Face(library, filePath.toStringz, 0, &face);
        if (err) assert(false, "Failed to load font!");

        err = FT_Set_Pixel_Sizes(face, size, size);
        if (err) assert(false, "Failed to set pixel size!");

        FT_Size_Metrics sz = face.size.metrics;
        maxWidthPerChar = cast(int)sz.max_advance / 64;
        baseLineHeight = cast(int)sz.ascender / 64;
        maxHeight = cast(int)(sz.ascender - sz.descender) / 64;
    }

    TextureObject renderText(wstring text, float font_size = this.size) {
        int len = cast(int)text.length;
        int texWidth = cast(int)(cast(float)maxWidthPerChar*len*font_size/size);
        int texHeight = cast(int)(cast(float)maxHeight*font_size/size);
        TextureObject texture = new TextureObject(texWidth,texHeight,ImageType.RGBA);
        static FrameBufferObject fbo;
        if (fbo is null) fbo = new FrameBufferObject;
        fbo.attachTextureAsColor(texture);
        fbo.write(texture.width, texture.height, {
            int x = 0;
            foreach (c; text) {
                TextureObject charaTex = getCharacterTexture(c);
                uint width = cast(uint)(cast(float)charaTex.width / size * font_size);
                uint height = cast(uint)(cast(float)charaTex.height / size * font_size);
                //writeln("(poo) width * height = " ~ "(" ~ to!string(width) ~ "," ~ to!string(font_size) ~ ")" );
                //writeln("(tex) width * height = " ~ "(" ~ to!string(charaTex.width) ~ "," ~ to!string(charaTex.height) ~ ")" );
                /*
        drawImage(x+width/2, height/2, width, height, charaTex);
*/
                x += width;
            }
        });
        return texture;
    }

    TextureObject getCharacterTexture(T)(inout T character) if (is (T == char) || is (T == wchar) || is (T == dchar)) {
        int charcode = cast(int)character;
        auto result = charcode in textures;
        if (result) return *result;

        return getCharacterTextureFromCode(charcode);
    }

    private TextureObject getCharacterTextureFromCode(int charcode) {

        auto err = FT_Load_Char(face, charcode, 0);
        if (err) assert (false, "Failed to load character!");

        err = FT_Render_Glyph(face.glyph, loadType);
        if (err) assert (false, "Failed to render glyph!!");

        FT_Bitmap bm = face.glyph.bitmap;

        /*
Note:FT_Bitmapについて:
rows:縦に何ピクセルあるか
width:横に何ピクセルあるか
pitch:横1列で何Byteあるか

buffer:
MONOの場合:	1ピクセルあたり1bit。ビットが立っていれば塗って、そうでなければ塗らない
NORMALの場合: 1ピクセルあたり1Byte。0~0xffでそのピクセルのα値を表す。
     */

        // ベースラインを考慮してTextureObjectに込めるようにします
        // FT_Pos := signed long です

        FT_Glyph_Metrics met = face.glyph.metrics;
        // FT_Pos met.width
        // FT_Pos met.height
        // FT_Pos met.horiBearingX
        // FT_Pos met.horiBearingY
        // FT_Pos met.horiAdvance

        // buffer width := met.advance
        // buffer height:= maxHeight

        uint advance = cast(uint)met.horiAdvance/64;
        uint bearingX = cast(uint)met.horiBearingX/64;
        uint width = cast(uint)met.width/64;
        uint bearingY = cast(uint)met.horiBearingY/64;
        uint height = cast(uint)met.height/64;

        ubyte[] buffer;
        final switch (loadType) {
        case LoadType.Mono:
            foreach_reverse (i; 0..maxHeight) {
                foreach (j; 0..advance) {
                    if( (j < bearingX) || (j >= bearingX + width) ||
                            (i < baseLineHeight-bearingY) ||
                            (i >= baseLineHeight-bearingY + height) ){
                        buffer ~= [0,0,0,0];
                    }else{
                        int row = i - (baseLineHeight - bearingY);
                        int col = j - bearingX;
                        auto c = bm.buffer[bm.pitch * row + col];
                        foreach_reverse (bit; 0..8) {
                            if (((c >> bit) & 1) == 0) {
                                buffer ~= [0, 0, 0, 0];
                            } else {
                                buffer ~= [0xff, 0xff, 0xff, 0xff];
                            }
                        }
                    }
                }
            }
            //foreach_reverse (row; 0..bm.rows) {
            //	foreach (col; 0..bm.pitch){
            //		auto c = bm.buffer[bm.pitch * row + col];
            //		foreach_reverse (bit; 0..8) {
            //			if (((c >> bit) & 1) == 0) {
            //				buffer ~= [0, 0, 0, 0];
            //			} else {
            //				buffer ~= [0xff, 0xff, 0xff, 0xff];
            //			}
            //		}
            //	}
            //}
            return textures[charcode] = new TextureObject(buffer.ptr, advance*8, maxHeight);
        case LoadType.AntiAlias:
            foreach_reverse (i; 0..maxHeight) {
                foreach (j; 0..advance) {
                    if( (j < bearingX) || (j >= bearingX + width) ||
                            (i < baseLineHeight-bearingY) ||
                            (i >= baseLineHeight-bearingY + height) ){
                        buffer ~= [0,0,0,0];
                    }else{
                        int row = i - (baseLineHeight - bearingY);
                        int col = j - bearingX;
                        auto c = bm.buffer[bm.pitch * row + col];
                        buffer ~= [0xff,0xff,0xff,c];
                    }
                }
            }
            //foreach_reverse (row; 0..bm.rows) {
            //	foreach (col; 0..bm.pitch){
            //		auto c = bm.buffer[bm.pitch * row + col];
            //		buffer ~= [0xff, 0xff, 0xff, c];
            //	}
            //}
            return textures[charcode] = new TextureObject(buffer.ptr, advance, maxHeight);
        }
    }

}
