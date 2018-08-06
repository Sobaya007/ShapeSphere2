module sbylib.render.Renderer;

public {
    import sbylib.core.World;
    import sbylib.render.RenderTarget;
    import sbylib.render.Viewport;
    import sbylib.entity.Entity;
}

class Renderer {

    private World world;
    protected IRenderTarget target;
    private IViewport viewport;

    this(World world, IRenderTarget target, IViewport viewport)
        in(world !is null)
        in(target !is null)
        in(viewport !is null)
    {
        this.world = world;
        this.target = target;
        this.viewport = viewport;
    }

    void renderBegin() {
        viewport.set();
        target.renderBegin();
    }

    void renderEnd() {
        target.renderEnd();
    }

    void render(string renderGroupName) {
        renderBegin();
        world.render(renderGroupName);
        renderEnd();
    }

    void renderAll() {
        renderBegin();
        world.renderAll();
        renderEnd();
    }
}
