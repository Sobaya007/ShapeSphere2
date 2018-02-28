module sbylib.wrapper.freetype.StringTexture;

import derelict.freetype.ft;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Font;

class StringTexture {

//    // wrapWidthは文字の高さを1としたときのサイズ
//    static auto createBuffer(Font font, ref dstring str, float wrapWidth = float.infinity) {
//        LetterInfo[] infos;
//        auto w = 0;
//        import std.array;
//        while (!str.empty) {
//            auto info = font.getLetterInfo(str.front);
//            if (w + info.maxWidth > wrapWidth*font.size) break;
//            infos ~= LetterInfo(info, w);
//            str = str[1..$];
//            w += info.maxWidth;
//        }
//        return infos;
//    }
}
