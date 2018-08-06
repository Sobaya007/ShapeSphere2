module sbylib.render.PostProcessRenderer;

import sbylib.render.Renderer;

class PostProcessRenderer : Renderer {

    import sbylib.wrapper.gl.Texture;
    import sbylib.utils.Compute;

    private Texture dst;
    private Texture[] colorTextureList;
    private ComputeProgram program;

    this(World world, IRenderTarget target, IViewport viewport, ComputeProgram program) {
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
        blitsTo(colorTextureList, target);
    }

    ComputeProgram getProgram() {
        return this.program;
    }
}
