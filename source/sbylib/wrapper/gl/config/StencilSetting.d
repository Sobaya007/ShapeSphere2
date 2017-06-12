module sbylib.wrapper.gl.config.StencilSetting;

import sbylib.wrapper.gl;
import derelict.opengl;

struct Stencilsetting {
    /**ステンシルバッファの設定
    StencilTestがtrueのときに
    (現在のステンシル値&Mask)と(Eval&Mask)をFuncで比較

    例えば、FuncがLessのときには
    現在のステンシル値 < Eval
    のときに有効となる。

    書き込まれるステンシル値は以下のように決定する。

    if (ステンシルテストに失敗) StencilFailure
    else if (デプステストに失敗) DepthFailure
    else Success

   */
    StencilFunc func = StencilFunc.Always;
    uint eval = 1;
    uint mask = ~0;
    StencilWrite stencilFailure = StencilWrite.Keep;
    StencilWrite depthFailure = StencilWrite.Keep;
    StencilWrite success = StencilWrite.Keep;

    package void exec() @nogc const {
        glStencilFunc(func, eval, mask);
        glStencilOp(stencilFailure, depthFailure, success);
    }
}

