module sbylib.utils.Compute;

import sbylib.wrapper.gl.Program;

class ComputeProgram : Program {

    import sbylib.wrapper.gl.Texture;
    import sbylib.utils.Path;

    private int localX, localY;

    this(ShaderPath path, int localX = 1, int localY = 1) {
        import std.file : readText;
        this(readText(path), localX, localY);
    }

    this(string sourceCode, int localX=1, int localY=1) {
        import sbylib.wrapper.gl.Shader;
        import sbylib.wrapper.gl.Constants;
        import sbylib.material.glsl;

        this.localX = localX;
        this.localY = localY;

        auto ast = new Ast(sourceCode);
        ast.completeVersionDeclare();
        ast.completeComputeLayoutDeclare(localX, localY);
        super([new Shader(ast.getCode(), ShaderType.Compute)]);
    }

    void compute(Texture texture) 
        in(texture.width  % this.localX == 0)
        in(texture.height % this.localY == 0)
    {
        import sbylib.wrapper.gl.Constants;
        import sbylib.wrapper.gl.Functions;

        this.use();
        texture.bindForCompute(0,0,false,0, BufferAccess.Write);
        GlFunction().dispatchCompute(texture.width/localX, texture.height/localY, 1);
    }
}
