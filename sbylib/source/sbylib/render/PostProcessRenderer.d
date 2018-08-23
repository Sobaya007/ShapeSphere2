module sbylib.render.PostProcessRenderer;

import sbylib.render.Renderer;

class PostProcessRenderer : Renderer {

    import sbylib.wrapper.gl.Texture;
    import sbylib.utils.Compute;

    private Texture dst;
    private Texture[] colorTextureList;
    private ComputeProgram program;
    private RenderTarget internalTarget;
    private RenderTarget realTarget;

    this(World world, RenderTarget target, IViewport viewport, ComputeProgram program) {
        this.internalTarget = new RenderTarget(target.width, target.height);
        this.internalTarget.attachTexture!(float)(FramebufferAttachType.Color0);
        this.internalTarget.attachTexture!(float)(FramebufferAttachType.Color1);
        this.internalTarget.attachRenderbuffer!(ubyte)(FramebufferAttachType.Depth);
        this.realTarget = target;
        super(world, target, viewport);
        this.program = program;

        if (auto t = cast(RenderTarget)target) {
            import std.range : walkLength;
            this.colorTextureList.length = t.getColorTextures().walkLength;
        } else {
            this.colorTextureList.length = 1;
        }

        import sbylib.wrapper.gl.Constants;
        TextureBuilder().width  = target.width;
        TextureBuilder().height = target.height;
        TextureBuilder().iformat = ImageInternalFormat.RGBA32F;
        this.dst = TextureBuilder().build!(float);

    }

    override void renderBegin() {
        this.internalTarget.clear(ClearMode.Color, ClearMode.Depth, ClearMode.Stencil);
        super.renderBegin();
    }

    override void renderEnd() {
        import sbylib.utils.Functions;

        super.renderEnd();
        this.program.compute(dst);
        
        if (auto target = cast(RenderTarget)this.target) {
            foreach (t; target.getColorTextures()) {
                import sbylib.wrapper.gl.Functions;
                colorTextureList[GlUtils.getColorAttachTypeIndex(t.key)] = t.value;
            }
        }
        colorTextureList[0] = dst;
        blitsTo(colorTextureList, realTarget);
        //blitsTo(dst, realTarget);
        //blitsTo(internalTarget.getColorTexture(0), realTarget);
        //(cast(IRenderTarget)internalTarget).blitsTo(realTarget, BufferBit.Color);
    }

    ComputeProgram getProgram() {
        return this.program;
    }

    RenderTarget getInternalTarget() {
        return this.internalTarget;
    }
}
