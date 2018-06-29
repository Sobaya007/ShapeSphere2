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
        auto findResult = keys.find!(keyButton => keyButton.to!string == key);
        assert(!findResult.empty, format!"'%s' is not a valid key name"(key));
        auto button = findResult.front;

        switch (command.type) {
            case JSON_TYPE.STRING:
                Core().getKey().justPressed(button).add(getCommand(command.str()));
                break;
            case JSON_TYPE.OBJECT:
                Core().getKey().justPressed(button).add(getCommand(command.object()));
                break;
            default:
                assert(false, format!"Key Command %s's value must be string or object"(key));
        }
    }
}

private auto getCommand(string command) {
    switch (command) {
        case "End": return &Core().end;
        case "ScreenShot": return { screenShot("ScreenShot.png"); };
        default: assert(false, format!"'%s' is not a valid command name"(command));
    }
}

private auto getCommand(JSONValue[string] obj) {
    auto type = obj.fetch!(string)("type")
        .getOrError("command must have paramter 'type' as string");
    switch (type) {
        case "ScreenShort":
            auto path = obj.fetch!(string)("path").getOrElse("ScreenShot.png");
            return { screenShot(path); };
        default: assert(false, format!"'%s' is not a valid command name"(type));
    }
}

private JsonWorld createWorld(string name, JSONValue[string] worldContent) {
    string templateType = worldContent.fetch!string("template").getOrElse("");
    auto target = worldContent.fetch!(JSONValue[string])("target")
        .fmap!(t => createTarget(t))
        .getOrElse(Core().getWindow().getScreen);

    auto world = new World;
    if (templateType == "2D") world.configure2D();

    foreach (name, content; worldContent) {
        assert(content.type == JSON_TYPE.OBJECT, format!"%s's value is not an object"(name));
        auto obj = content.object();
        string type = obj.fetch!string("type")
            .getOrError(format!"%s must have 'type' as string"(name));
        switch (type) {
            case "PerspectiveCamera":
                auto camera = createPerspectiveCamera(name, obj);
                setCamera(world, camera, target, templateType);
                break;
            case "PixelCamera":
                auto camera = createPixelCamera(name, obj);
                setCamera(world, camera, target, templateType);
                break;
            case "PointLight":
                world.add(createPointLight(name, obj));
                break;
            case "Model":
                world.add(createModel(name, obj));
                break;
            case "Text":
                world.add(createLabel(name, obj));
                break;
            case "Entity":
                world.add(createEntity(name, obj));
                break;
            default:
                assert(false, format!"Unknown type '%s'"(type));
        }
    }
    return JsonWorld(world, target);
}

private void setCamera(World world, Camera camera, IRenderTarget target, string templateType) {
    if (templateType == "3D") world.configure3D(camera, target);
    else world.setCamera(camera);
}

private PerspectiveCamera createPerspectiveCamera(string name, JSONValue[string] param) {
    auto camera = new PerspectiveCamera();
    camera.name = name;
    camera.aspectWperH = Core().getWindow().width / Core().getWindow().height;
    setParameter!(
        ParamList!(
            PerspectiveCamera,
            Param!("fovy", Degree, true),
            Param!("nearZ", float, true),
            Param!("farZ", float, true),
            Param!("aspectWperH", float, false),
            Param!("pos", vec3, false),
            Param!("lookAt", vec3, false)
        )
    )(camera, param);
    return camera;
}

private PixelCamera createPixelCamera(string name, JSONValue[string] param) {
    auto camera = new PixelCamera();
    camera.name = name;
    setParameter!(
        ParamList!(
            PixelCamera,
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
    params.fetch!(JSONValue[string])("stencil").apply!((stencil) {
        auto type = stencil.fetch!string("type").getOrError("'stencil' must have 'type' as string");
        auto object = stencil.fetch!string("object").getOrError("'stencil' must have 'object' as string");
        getAttachFunc(result, type, object)(FrameBufferAttachType.Stencil);
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

private PointLight createPointLight(string name, JSONValue[string] param) {
    auto light = new PointLight();
    light.name = name;
    setParameter!(
        ParamList!(
            PointLight,
            Param!("pos", vec3, true),
            Param!("diffuse", vec3, true)
            )
        )(light, param);
    return light;
}

private Entity createModel(string name, JSONValue[string] param) {
    auto path = ModelPath(param.fetch!string("path")
            .getOrError("'Model' must have path as a string"));
    auto material = param.fetch!bool("material").getOrElse(true);
    auto normal = param.fetch!bool("normal").getOrElse(true);
    auto uv = param.fetch!bool("uv").getOrElse(true);
    auto model = XLoader().load(path, material, normal, uv).buildEntity();
    model.name = name;
    setParameter!(
        ParamList!(
            Entity,
            Param!("pos", vec3, true),
        )
    )(model, param);
    return model;
}

private Label createLabel(string name, JSONValue[string] param) {
    auto pos = param.fetch!vec3("pos").getOrElse(vec3(0));
    LabelFactory factory;
    setParameter!(
        ParamList!(
            LabelFactory,
            Param!("fontName", string, false),
            Param!("text", dstring, false),
            Param!("height", float, false),
            Param!("fontResolution", int, false),
            Param!("wrapWidth", float, false),
            Param!("textColor", vec4, false),
            Param!("backColor", vec4, false),
        )
    )(factory, param);
    auto label = factory.make();
    label.name = name;
    label.pos = pos;
    return label;
}

private Entity createEntity(string name, JSONValue[string] params) {
    alias G = ParamList;
    alias M = ParamList;
    import std.meta;

    alias Geoms = AliasSeq!(
        G!(Rect),
        G!(Box),
        G!(Dodecahedron),
        G!(Plane),
        G!(Sphere),
        G!(SphereUV),
    );
    alias Mats = AliasSeq!(
        M!(ColorMaterial, Param!("color", vec4, true)),
        M!(LambertMaterial, Param!("ambient", vec3, true), Param!("diffuse", vec3, true)),
        M!(NormalMaterial),
        M!(PhongMaterial, Param!("ambient", vec4, true), Param!("diffuse", vec3, true), Param!("specular", vec3, true)),
        M!(TextureMaterial),
        M!(CheckerMaterial!(ColorMaterial, ColorMaterial), Param!("color1", vec4, true), Param!("color2", vec4, true), Param!("size", float, true)),
        M!(UvMaterial),
        M!(WireframeMaterial)
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
                    entity.name = name;
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

private void setParameter(ParamList)(ref ParamList.Type entity, JSONValue[string] params) {
    static foreach (Param; ParamList.Params) {
        entity.setParameter!(Param.Name, Param.Type, Param.Necessary)(params);
    }

    import std.array, std.range;
    assert(params.keys.empty, format!"Unknown Parameters: '%s'"(params.keys.join(", ")));
}

private void setParameter(string paramName, ParamType, bool necessary, E)(ref E target, JSONValue[string] params) {
    auto value = params.fetch!ParamType(paramName);
    if (value.isNone) {
        static if (necessary) assert(false, format!"'%s' must have '%s' as '%s'"(target.name, paramName, ParamType.stringof));
        else return;
    }
    mixin("target."~paramName) = value.get();
}

private auto fetch(Type)(JSONValue[string] object, string key) {
    auto result = object.at(key).fmapAnd!((JSONValue v) => wrapException!(() => v.as!Type));
    if (result.isJust) object.remove(key);
    return result;
}
