module sbylib.wrapper.gl.UniformBuffer;

import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Uniform;

class UniformBuffer(T) : BufferObject!(BufferType.Uniform, T), Uniform {

    import sbylib.wrapper.gl.Program;

    string name;

    this(string name) {
        this.name = name;
        super();
    }

    override string getName() const {
        return this.name;
    }

    override void setName(string name) {
        this.name = name;
    }

    override void apply(const Program program, ref uint uniformBlockPoint, ref uint textureUnit) const {
        import sbylib.wrapper.gl.Functions;
        auto loc = this.getLocation(program);
        GlFunction().uniformBlockBinding(program.id, loc, uniformBlockPoint);
        GlFunction().bindBufferBase(BufferType.Uniform, uniformBlockPoint, this.id);
        uniformBlockPoint++;
    }

    private uint getLocation(const Program program) const {
        import sbylib.wrapper.gl.Functions;
        auto loc = GlFunction().getUniformBlockIndex(program.id, this.name);
        assert(loc != -1, name ~ " is not found or used."); 
        return loc;
    }

}
