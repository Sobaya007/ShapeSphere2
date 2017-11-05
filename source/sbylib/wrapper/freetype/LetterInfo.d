module sbylib.wrapper.freetype.LetterInfo;

import derelict.freetype.ft;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.freetype.Constants;

class LetterInfo {
    Texture texture;
    ulong width, height;

    this(FT_GlyphSlotRec* glyph, FT_Size_Metrics sz, FontType fontType) {
        // ベースラインを考慮してTexture込めるようにします
        // FT_Pos := signed long です                                                                                }
        FT_Glyph_Metrics met = glyph.metrics;
        // FT_Pos met.width
        // FT_Pos met.height
        // FT_Pos met.horiBearingX
        // FT_Pos met.horiBearingY
        // FT_Pos met.horiAdvance

        // buffer width := met.advance
        // buffer height:= maxHeight

        auto bearingX = met.horiBearingX/64;
        auto bearingY = met.horiBearingY/64;
        auto width = met.width/64;
        auto height = met.height/64;

        auto baseLineHeight = sz.ascender / 64;
        auto maxWidth = met.horiAdvance/64;
        auto maxHeight = (sz.ascender - sz.descender) / 64;

        auto bm = glyph.bitmap;

        ubyte[] buffer;
        foreach_reverse (y; 0..maxHeight) {
            foreach (x; 0..maxWidth) {
                if (   x < bearingX
                    || y < baseLineHeight-bearingY
                    || x >= bearingX + width
                    || y >= baseLineHeight-bearingY+height) {
                    buffer ~= 0;
                } else {
                    auto row = y - (baseLineHeight - bearingY);
                    auto col = x - bearingX;
                    auto c = bm.buffer[bm.pitch * row + col];
                    buffer ~= c;
                }
            }
        }

        GlFunction.setPixelUnpackAlign(1);
        auto texture = new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.R, cast(uint)maxWidth, cast(uint)maxHeight, ImageFormat.R, buffer.ptr);
        GlFunction.setPixelUnpackAlign(4);

        texture.setWrapS(TextureWrap.ClampToEdge);
        texture.setWrapT(TextureWrap.ClampToEdge);

        this.texture = texture;
        this.width = maxWidth;
        this.height = maxHeight;
    }
}
