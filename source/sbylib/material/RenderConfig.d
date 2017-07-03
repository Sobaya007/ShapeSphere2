module sbylib.material.RenderConfig;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;

class RenderConfig {
    TestFunc depthFunc;
    PolygonMode polygonMode;
    FaceMode faceMode;
    TestFunc stencilFunc;
    uint stencilValue;
    uint stencilMask;
    StencilWrite sfail, dpfail, pass;
    BlendFactor srcFactor, dstFactor;
    BlendEquation blendEquation;

    this() {
        this.depthFunc = TestFunc.Less;
        this.polygonMode = PolygonMode.Fill;
        this.faceMode = FaceMode.FrontBack;
        this.stencilFunc = stencilFunc.Always;
        this.stencilValue = 1;
        this.stencilMask = 1;
        this.sfail = StencilWrite.Keep;
        this.dpfail = StencilWrite.Keep;
        this.pass = StencilWrite.Keep;
        this.srcFactor = BlendFactor.SrcAlpha;
        this.dstFactor = BlendFactor.OneMinusSrcAlpha;
        this.blendEquation = BlendEquation.Add;
    }

    void set() {
        GlFunction.depthFunc(this.depthFunc);
        GlFunction.faceSetting(this.polygonMode, this.faceMode);
        GlFunction.stencil(this.stencilFunc, this.stencilValue, this.stencilMask, this.sfail, this.dpfail, this.pass);
        GlFunction.blendFunc(this.srcFactor, this.dstFactor);
        GlFunction.blendEquation(this.blendEquation);
    }
}
