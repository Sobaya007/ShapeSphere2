module sbylib.material.glsl.Sharp;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Space;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.UniformDemand;

import std.format;
import std.algorithm;
import std.range;

class Sharp : Statement {
    string type;
    string value;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "#");
        this.type = convert(tokens);
        this.value = convert(tokens);
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
        else
            return "";
    }

    Space getVertexSpace() in {
        assert(this.type == "vertex");
    } body {
        return convert!(Space, getSpaceName)(this.value);
    }

    RequireAttribute getRequireAttribute() in {
        assert(this.type == "vertex");
    } body {
        return new RequireAttribute(format!"require Position in %s as vec3 po;"(this.value));
    }

    string getGlPositionCode() in {
        assert(this.type == "vertex");
    } body {
        return format!"gl_Position = %s * vec4(position,1);"(this.getVertexSpace().getUniformDemands().map!(u => getUniformDemandName(u)).join(" * "));
    }
}
