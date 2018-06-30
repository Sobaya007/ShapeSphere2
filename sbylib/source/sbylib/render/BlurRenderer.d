module sbylib.render.BlurRenderer;

import sbylib.render.Renderer;
import sbylib.utils.Path;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.UniformTexture;

/*
class BlurRenderer : Renderer {

    private IRenderTarget realTarget;
    private RenderTarget intermediateTarget;
    private Texture intermediatetTexture;
    private Program program;

    this(World world, IRenderTarget target, IViewport viewport) {
        this.realTarget = target;
        this.intermediateTarget = new RenderTarget(target.width, target.height);
        this.intermediateTarget.attachTexture!(uint)(FrameBufferAttachType.Color0);
        this.intermediateTarget.attachRenderBuffer!(uint)(FrameBufferAttachType.Depth);
        this.intermediateTarget.attachRenderBuffer!(uint)(FrameBufferAttachType.Stencil);
        super(world, this.intermediateTarget, viewport);

        this.intermediatetTexture = new Texture(TextureTarget.Tex2D);
        0, ImageInternalFormat.RGBA, target.width, target.height, ImageFormat.RGBA, null);

        import std.file;
        this.program = new Program([new Shader(readText(ShaderPath("star.comp")), ShaderType.Compute)]);
        this.program.applyAllUniform(cast(Uniform[])[
            new utexture("inputTexture", this.intermediateTarget.getColorTexture()),
        ]);
    }


    override void render() {
        super.render(); 
        tex.bindForCompute(0,0,false,0, BufferAccess.Write);
        GlFunction.dispatchCompute(tex.width/32, tex.height/32, 1);
    }
}
*/
