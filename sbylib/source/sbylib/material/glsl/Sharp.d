module sbylib.material.glsl.Sharp;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Space;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.UniformDemand;
import sbylib.utils.Maybe;

import std.format;
import std.algorithm;
import std.range;

class Sharp : Statement {
    string type;
    string value;
    Maybe!string value2;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "#");
        this.type = convert(tokens);
        this.value = convert(tokens);

        if (!tokens.empty && tokens.front.str == ":") {
            expect(tokens, ":");
            this.value2 = Just(convert(tokens));
        }
    }

    static generateVersionDeclare() {
        import sbylib.wrapper.gl.GL;
        return new Sharp(format!"#version %d"(GL.getShaderVersion()));
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Sharp\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.value ~ "\n";
        return code;
    }

    override string getCode() {
        if (this.type == "version")
            return format!"#%s %s"(this.type, this.value);
        else if (this.type == "extension") 
            return format!"#%s %s : %s"(this.type, this.value, this.value2.unwrap());
        else
            return "";
    }

    Space getVertexSpace()
        in(this.type == "vertex")
    {
        return convert!(Space, getSpaceName)(this.value);
    }

    RequireAttribute getRequireAttribute()
        in(this.type == "vertex")
    {
        return new RequireAttribute(format!"require Position in %s as vec4 gl_Position;"(this.value));
    }
}
