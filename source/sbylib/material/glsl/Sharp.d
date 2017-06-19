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

    this() {}

    this(ref Token[] tokens) {
        assert(tokens[0].str == "#");
        this.type = tokens[1].str;
        this.value = tokens[2].str;
        tokens = tokens[3..$];
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Sharp\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.value ~ "\n";
        return code;
    }

    override string getCode() {
        return format!"#%s %s"(this.type, this.value);
    }

    Space getVertexSpace() in {
        assert(this.type == "vertex");
    } body {
        return find!(Space, getSpaceName)(this.value);
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
