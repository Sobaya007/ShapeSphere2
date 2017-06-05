module sbylib.primitive.PolyHedron;

import sbylib;

//多面体を表すクラスです。
//凸でなくても問題なく動作します
class PolyHedron : Primitive {

    private {
        FaceList mFaceList;
    }

    this(FaceList faces) {
        this.mFaceList = faces;
        super(faces, ShaderStore.getShader("NormalGenerate"));
    }

}
