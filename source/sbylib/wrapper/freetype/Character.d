module sbylib.wrapper.freetype.Character;

import derelict.freetype.ft;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Functions;
import sbylib.core.RenderTarget;
import sbylib.wrapper.freetype.Constants;

class Character {
    Texture texture;

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

        uint bearingX = cast(uint)met.horiBearingX/64;
        uint bearingY = cast(uint)met.horiBearingY/64;
        uint width = cast(uint)met.width/64;
        uint height = cast(uint)met.height/64;

        uint baseLineHeight = cast(int)sz.ascender / 64;
        uint maxWidth = cast(uint)met.horiAdvance/64;
        uint maxHeight = cast(int)(sz.ascender - sz.descender) / 64;

        import std.stdio;
        writeln(glyph.bitmap.pitch);
        writeln(width);
        writeln(height);
        writeln(bearingX);
        writeln(bearingY);

        writeln(baseLineHeight);

        writeln(maxWidth);
        writeln(maxHeight);
        auto bm = glyph.bitmap;

        ubyte[] buffer;
 //       foreach_reverse (i; 0..maxHeight) {
 //           foreach (j; 0..advance) {
 //               if( (j < bearingX) || (j >= bearingX + width) ||
 //                       (i < baseLineHeight-bearingY) ||
 //                       (i >= baseLineHeight-bearingY + height) ){
 //                   buffer ~= 0;
 //               }else{
 //                   int row = i - (baseLineHeight - bearingY);
 //                   int col = j - bearingX;
 //                   auto c = bm.buffer[bm.pitch * row + col];
 //                   final switch (fontType) {
 //                   case FontType.Mono:
 //                       foreach_reverse (bit; 0..8) {
 //                           buffer ~= 0xff;
 //                           //if (((c >> bit) & 1) == 0) {
 //                           //    buffer ~= 0;
 //                           //} else {
 //                           //    buffer ~= 0xff;
 //                           //}
 //                       }
 //                       break;
 //                   case FontType.AntiAlias:
 //                       buffer ~= c;
 //                       break;
 //                   }
 //               }
 //           }
 //       }
        foreach (y; 0..maxHeight) {
            foreach (x; 0..maxWidth) {
                if (   x < bearingX
                    || y < baseLineHeight-bearingY
                    || x >= bearingX + width
                    || y >= baseLineHeight-k) {
                }
                if (i < height /2 && j < width / 2) {
                    buffer ~= 0xff;
                } else {
                    buffer ~= 0;
                }
            }
        }
//        uint maxWidth;
//        final switch (fontType) {
//        case FontType.Mono:
//            maxWidth = advance*8;
//            break;
//        case FontType.AntiAlias:
//            maxWidth = advance;
//            break;
//        }

        setPixelUnpackAlign(1);
        auto texture = new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.R, maxWidth, maxHeight, ImageFormat.R, buffer.ptr);
        setPixelUnpackAlign(4);
 //       auto texture = new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.R, maxWidth, maxHeight, ImageFormat.R, buffer.ptr);
//        auto texture = new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.R, bm.width, bm.rows, ImageFormat.R, bm.buffer);

        texture.setWrapS(TextureWrap.ClampToEdge);
        texture.setWrapT(TextureWrap.ClampToEdge);

        this.texture = texture;
    }
}
