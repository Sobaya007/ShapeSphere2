module sbylib.wrapper.gl.config.RenderConfig;

import sbylib.wrapper.gl;
import derelict.opengl;

struct RenderConfig {
    private Stencilsetting stencilsetting;

    @nogc {

        /**
      カリングの設定。
     */
        void cullFace(bool f){
            if(f)glEnable(GL_CULL_FACE);
            else glDisable(GL_CULL_FACE);
        }

        /**
      深度テストの設定。
     */
        void depthTest(bool f){
            if(f)glEnable(GL_DEPTH_TEST);
            else glDisable(GL_DEPTH_TEST);
        }

        /**
      深度マスクの設定。trueにすると深度バッファへ書き込みをしなくなります。
     */
        void depthMask(bool f){
            if(f)glDepthMask(GL_TRUE);
            else glDepthMask(GL_FALSE);
        }

        /**
      ワイヤーフレームの設定。trueにするとワイヤーフレーム表示になります。
     */
        void wireframe(bool f) {
            if (f) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            else   glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }

        /**
      ステンシルテストの設定。trueにするとステンシルバッファを読み取りそれに応じた処理を行います。
     */
        void stencilTest(bool f, void function(ref Stencilsetting d) @nogc s){
            s(stencilsetting);
            if(f){
                glEnable(GL_STENCIL_TEST);
                stencilsetting.exec();
            }else glDisable(GL_STENCIL_TEST);
        }

        /**
      合成方法の設定。src(書き込もうとしている色)とdst(書き込んである色)から次の色を決定する方法を決めます。
     */
        void blendEquation(BlendEquation b){
            glBlendEquation(b);
        }

        /**
      合成係数の設定。src(書き込もうとしている色)とdst(書き込んである色)に対する係数を決めます。
     */
        void blendFunc(BlendFunc src, BlendFunc dst) {
            glBlendFunc(src, dst);
        }

        /**
      設定の初期化。初期設定は
      カリング         - true
      深度テスト       - true
      深度マスク       - true
      ワイヤーフレーム - false
      ステンシル       - false
      合成方法         - Add
      合成係数         - One Zero
     */
        void defaulting(){
            cullFace(true);
            depthTest(true);
            depthMask(true);
            wireframe(false);
            stencilTest(false,(ref Stencilsetting d){});
            blendEquation(BlendEquation.Add);
            blendFunc(BlendFunc.SrcAlpha, BlendFunc.OneMinusSrcAlpha);
        }

    }
}
