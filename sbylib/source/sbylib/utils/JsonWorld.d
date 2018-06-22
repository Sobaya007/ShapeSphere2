module sbylib.utils.JsonWorld;

import std.json;
import std.format;
import sbylib;
import std.stdio;

struct JsonWorld {
    World world;
    IRenderTarget target;
}

JsonWorld[string] createFromJson(string path) {
    import std.file;

    auto root = parseJSON(readText(path));
    assert(root.type == JSON_TYPE.OBJECT, "root must be object");
    JsonWorld[string] worldList;

    foreach (key, value; root.object) {
        if (key == "KeyCommand") {
            assert(value.type == JSON_TYPE.OBJECT, "KeyCommand's value must be object");
            createKeyCommand(value.object());
        } else {
            assert(value.type == JSON_TYPE.OBJECT, format!"%s's value is not an object"(key));
            worldList[key] = createWorld(key, value.object());
        }
    }
    return worldList;
}

private void createKeyCommand(JSONValue[string] commandList) {
    import std.traits;
    import std.algorithm : find;
    import std.conv;
    import std.array;
    auto keys = [EnumMembers!KeyButton];
    foreach (key, command; commandList) {
        assert(command.type == JSON_TYPE.STRING, format!"Key Command %s's value is not a string"(key));
        auto findResult = keys.find!(keyButton => keyButton.to!string == key);
        assert(!findResult.empty, format!"'%s' is not a valid key name"(key));

        auto button = findResult.front;
        Core().getKey().justPressed(button).add(getCommand(command.str()));
    }
}

private auto getCommand(string command) {
    switch (command) {
        case "End": return &Core().end;
        default: assert(false, format!"'%s' is not a valid command name"(command));
    }
}

private JsonWorld createWorld(string name, JSONValue[string] worldContent) {
    string templateType = worldContent.fetch!string("template").getOrElse("");
    auto target = worldContent.fetch!(JSONValue[string])("target")
        .fmap!(t => createTarget(t))
        .getOrElse(Core().getWindow().getScreen);

    auto world = new World;
    foreach (name, content; worldContent) {
        assert(content.type == JSON_TYPE.OBJECT, format!"%s's value is not an object"(name));
        auto obj = content.object();
        string type = obj.fetch!string("type")
            .getOrError(format!"%s must have 'type' as string"(name));
        switch (type) {
            case "PerspectiveCamera":
                auto camera = createPerspectiveCamera(obj);
                camera.name = name;
                if (templateType == "3D") world.configure3D(camera, target);
                else world.setCamera(camera);
                break;
            case "PointLight":
                auto light = createPointLight(obj);
                light.name = name;
                world.add(light);
                break;
            case "Model":
                auto model = createModel(obj);
                model.name = name;
                world.add(model);
                break;
            case "Entity":
                auto entity = createEntity(obj);
                entity.name = name;
                world.add(entity);
                break;
            default:
                assert(false, format!"Unknown type '%s'"(type));
        }
    }
    return JsonWorld(world, target);
}

private PerspectiveCamera createPerspectiveCamera(JSONValue[string] param) {
    auto camera = new PerspectiveCamera();
    camera.aspectWperH = Core().getWindow().width / Core().getWindow().height;
    setParameter!(
        ParamList!(
            PerspectiveCamera,
            Param!("fovy", Degree, true),
            Param!("nearZ", float, true),
            Param!("farZ", float, true),
            Param!("pos", vec3, false),
            Param!("lookAt", vec3, false)
            )
        )(camera, param);
    return camera;
}

private IRenderTarget createTarget(JSONValue[string] params) {
    auto result = new RenderTarget(Core().getWindow().width, Core().getWindow().height);
    params.fetch!(JSONValue[string])("color").apply!((color) {
        auto type = color.fetch!string("type").getOrError("'color' must have 'type' as string");
        auto object = color.fetch!string("object").getOrError("'color' must have 'object' as string");
        getAttachFunc(result, type, object)(FrameBufferAttachType.Color0);
        color.fetch!vec4("clear").apply!((vec4 clear) => result.setClearColor(clear));
    });
    params.fetch!(JSONValue[string])("depth").apply!((depth) {
        auto type = depth.fetch!string("type").getOrError("'depth' must have 'type' as string");
        auto object = depth.fetch!string("object").getOrError("'depth' must have 'object' as string");
        getAttachFunc(result, type, object)(FrameBufferAttachType.Depth);
    });
    return result;
}

private void delegate(FrameBufferAttachType) getAttachFunc(RenderTarget target, string type, string object) {
    import std.meta : AliasSeq;
    import std.string : capitalize;

    void delegate(FrameBufferAttachType) func;
    switch (object) {
        static foreach (Func; AliasSeq!("texture", "renderBuffer")) {
            case Func:
                switch (type) {
                    static foreach (T; AliasSeq!(uint, float)) {
                        case T.stringof:
                            return &mixin("target.attach"~Func[0..1].capitalize~Func[1..$]~"!T");
                    }
                    default:
                        assert(false, format!"'%s' is not a valid type name"(type));
                }
        }
        default:
            assert(false, format!"'%s' is not a valid object name"(object));
    }
}

private PointLight createPointLight(JSONValue[string] param) {
    auto light = new PointLight();
    setParameter!(
        ParamList!(
            PointLight,
            Param!("pos", vec3, true),
            Param!("diffuse", vec3, true)
            )
        )(light, param);
    return light;
}

private Entity createModel(JSONValue[string] param) {
    auto path = ModelPath(param.fetch!string("path")
            .getOrError("'Model' must have path as a string"));
    auto material = param.fetch!bool("material").getOrElse(true);
    auto normal = param.fetch!bool("normal").getOrElse(true);
    auto uv = param.fetch!bool("uv").getOrElse(true);
    auto model = XLoader().load(path, material, normal, uv).buildEntity();
    setParameter!(
        ParamList!(
            Entity,
            Param!("pos", vec3, true),
        )
    )(model, param);
    return model;
}

private Entity createEntity(JSONValue[string] params) {
    alias G = ParamList;
    alias M = ParamList;
    import std.meta;

    alias Geoms = AliasSeq!(G!(Box));
    alias Mats = AliasSeq!(
        M!(NormalMaterial),
        M!(TextureMaterial)
    );

    auto geometry = params.fetch!string("geometry")
        .getOrError("Entity must have 'geometry' as string");
    auto material = params.fetch!string("material")
        .getOrError("Entity must have 'material' as string");
    static foreach(Geom; Geoms) {
        if (Geom.Type.stringof == geometry) {
            static foreach (Mat; Mats) {
                if (Mat.Type.stringof == material) {
                    auto entity = makeEntity(Geom.Type.create(), new Mat.Type);
                    setParameter!(
                        ParamList!(
                            typeof(entity),
                            Geom.Params,
                            Mat.Params,
                            Param!("pos", vec3, false),
                            Param!("scale", vec3, false),
                        )
                    )(entity, params);
                    return entity;
                }
            }
            assert(false, format!"Unknown material name '%s'"(material));
        }
    }
    assert(false, format!"Unknown geometry name '%s'"(geometry));
}

private struct Param(string name, type, bool necessary) {
    alias Name = name;
    alias Type = type;
    alias Necessary = necessary;
}

private struct ParamList(type, params...) {
    alias Type = type;
    alias Params = params;
}

private void setParameter(ParamList)(ParamList.Type entity, JSONValue[string] params) {
    static foreach (Param; ParamList.Params) {
        entity.setParameter!(Param.Name, Param.Type, Param.Necessary)(params);
    }

    import std.array, std.range;
    assert(params.keys.empty, format!"Unknown Parameters: '%s'"(params.keys.join(", ")));
}

private void setParameter(string paramName, ParamType, bool necessary, E)(E target, JSONValue[string] params) {
    auto value = params.fetch!ParamType(paramName);
    if (value.isNone) {
        static if (necessary) assert(false, format!"'%s' must have '%s'"(target.name, paramName));
        else return;
    }
    mixin("target."~paramName) = value.get();
}

private auto fetch(Type)(JSONValue[string] object, string key) {
    auto result = object.at(key).fmapAnd!((JSONValue v) => wrapException!(() => v.as!Type));
    if (result.isJust) object.remove(key);
    return result;
}
