module sbylib.utils.Universe;

import std.json;
import std.format;
import sbylib;
import std.stdio;
import std.meta;
import std.typecons;

class Universe {

    private World[string] worldList;
    private IRenderTarget[string] targetList;
    private Renderer[World] rendererList;

    private ProcessManager mProcess;
    private Key mKey;
    private Mouse mMouse;
    private JoyStick mJoy;
    private Maybe!Process thisUpdate;

    mixin Dispatch!(
        [
            "addProcess" : ["process.addProcess"],
            "appendLog" : ["process.appendLog"],
            "isPressed" :  ["key.isPressed", "mouse.isPressed", "joy.isPressed"],
            "isReleased" : ["key.isReleased", "mouse.isReleased", "joy.isReleased"],
            "justPressed" :  ["key.justPressed", "mouse.justPressed", "joy.justPressed"],
            "justReleased" : ["key.justReleased", "mouse.justReleased", "joy.justReleased"],
            "justPressedKey" : ["key.justPressedKey"],
            "justReleasedKey" : ["key.justReleasedKey"],
            "preventCallback" : ["key.preventCallback"],
            "allowCallback" : ["key.allowCallback"],
            "mousePos" : ["mouse.pos"],
            "mouseDif" : ["mouse.dif"],
            "justPressedButton" : ["mouse.justPressedButton"],
            "justReleasedButton" : ["mouse.justReleasedButton"],
            "joyCanUse" : ["joy.canUse"],
            "getAxis" : ["joy.getAxis"],
        ]
    );

    alias DefaultGeometryList = DefineGeometryList!(
        DefineGeometry!(Rect),
        DefineGeometry!(Box),
        DefineGeometry!(Dodecahedron),
        DefineGeometry!(Plane),
        DefineGeometry!(Sphere),
        DefineGeometry!(SphereUV),
    );

    alias DefaultMaterialList = DefineMaterialList!(
        DefineMaterial!(ColorMaterial, Param!("color", vec4, true)),
        DefineMaterial!(LambertMaterial, Param!("ambient", vec3, true), Param!("diffuse", vec3, true)),
        DefineMaterial!(NormalMaterial),
        DefineMaterial!(PhongMaterial, Param!("ambient", vec4, true), Param!("diffuse", vec3, true), Param!("specular", vec3, true)),
        DefineMaterial!(TextureMaterial),
        DefineMaterial!(CheckerMaterial!(ColorMaterial, ColorMaterial), Param!("color1", vec4, true), Param!("color2", vec4, true), Param!("size", float, true)),
        DefineMaterial!(UnrealFloorMaterial),
        DefineMaterial!(UvMaterial),
        DefineMaterial!(WireframeMaterial)
    );

    alias ConfigParamList = DefineParamList!(
        Param!("depthFunc", TestFunc, false),
        Param!("polygonMode", PolygonMode, false),
        Param!("faceMode", FaceMode, false),
        Param!("srcFactor", BlendFactor, false),
        Param!("dstFactor", BlendFactor, false),
        Param!("blendEquation", BlendEquation, false),
        Param!("blend", bool, false),
        Param!("colorWrite", bool, false),
        Param!("depthWrite", bool, false),
        Param!("depthTest", bool, false),
        Param!("stencilWrite", bool, false),
        Param!("stencilFunc", TestFunc, false),
        Param!("stencilValue", int, false),
        Param!("sfail", StencilWrite, false),
        Param!("dpfail", StencilWrite, false),
        Param!("pass", StencilWrite, false),
        Param!("renderGroupName", string, false),
    );

    alias ObjectParamList = DefineParamList!(
        Param!("pos", vec3, false),
        Param!("scale", vec3, false),
        Param!("lookAt", vec3, false),
    );

    void update() {
        this.key.update();
        this.mouse.update();
        this.joy.update();
        this.process.update();
    }

    void destroy() {
        foreach (name, world; worldList) world.destroy();
        foreach (name, target; targetList) target.destroy();
    }

    void pause() {
        thisUpdate.pause();
    }

    void resume() {
        thisUpdate.resume();
    }

    Maybe!(World) getWorld(string name) {
        return worldList.at(name);
    }

    Maybe!(IRenderTarget) getTarget(string name) {
        return targetList.at(name);
    }

    private Key key() {
        if (mKey is null)
            this.mKey = new Key(Core().getWindow());
        return mKey;
    }

    private Mouse mouse() {
        if (mMouse is null)
            this.mMouse = new Mouse(Core().getWindow());
        return mMouse;
    }

    private JoyStick joy() {
        if (mJoy is null)
            this.mJoy = new JoyStick();
        return mJoy;
    }

    private ProcessManager process() {
        if (mProcess is null)
            this.mProcess = new ProcessManager();
        return mProcess;
    }

    static Universe createFromJson(Additional...)(string path) {
        auto universe = new Universe();
        universe.createFromJsonImpl!(Additional)(path);
        return universe;
    }

    private void createFromJsonImpl(Additional...)(string path) {

        this.targetList["Screen"] = Core().getWindow().getScreen(); //for Core Implementation, initialization is placed here.

        import std.file;

        auto root = wrapException!(() => parseJSON(readText(path)).as!(JSONValue[string]))
            .getOrError("root must be object");

        auto keyCommand = root.fetch("KeyCommand");
        if (keyCommand.isJust) {
            createKeyCommand(
                wrapException!(() => keyCommand.get().as!(JSONValue[string]))
                .getOrError("KeyCommand's value must be object")
            );
        }

        auto render = root.fetch("Render");

        foreach (key, value; root) {
            assert(value.type == JSON_TYPE.OBJECT, format!"%s's value is not an object"(key));
            createWorld!(Additional)(key, value.object());
        }
        if (render.isJust) {
            createRender(
                wrapException!(() => render.get().as!(JSONValue[]))
                .getOrError("Render's value must be object")
            );
        } else {
            auto worldName = worldList.keys.wrapRange();
            if (worldName.isJust) {
                createRender(parseJSON(format!q{
                    [
                        "Clear",
                        {
                            "type" : "Render",
                            "target" : "%s"
                        }
                    ]
                }(worldName.get())).array);
            }
        }
        thisUpdate = Just(Core().addProcess(&update, "universe"));
    }

    private void createKeyCommand(JSONValue[string] commandList) {
        import std.conv;

        foreach (key, command; commandList) {
            auto button = wrapException!(() => key.to!KeyButton)
                .getOrError(format!"'%s' is not a valid key name"(key));

            this.justPressed(button).add(createCommand(command));
        }
    }

    private void createRender(JSONValue[] array) {
        import std.algorithm : map;
        import std.array;

        auto process = array.map!(v => createCommand(v)).array;
        this.addProcess({ foreach (proc; process) proc();}, "Render");
    }

    private void createWorld(Additional...)(string name, JSONValue[string] worldContent) {

        auto templateType = worldContent.fetch!string("template");

        auto world = new World;
        worldList[name] = world;

        Maybe!Camera camera;
        IRenderTarget target = Core().getWindow().getScreen();
        Entity[] entities;

        foreach (name, content; worldContent) {
            assert(content.type == JSON_TYPE.OBJECT, format!"%s's value is not an object"(name));
            auto obj = content.object();
            string type = obj.fetch!string("type")
                .getOrError(format!"%s must have 'type' as string"(name));
            switch (type) {
                case "PerspectiveCamera":
                    assert(camera.isNone, "camera is already defined");
                    camera = Just(createPerspectiveCamera(name, obj));
                    break;
                case "PixelCamera":
                    assert(camera.isNone, "camera is already defined");
                    camera = Just(createPixelCamera(name, obj));
                    break;
                case "PointLight":
                    entities ~= createPointLight(name, obj);
                    break;
                case "Model":
                    entities ~= createModel(name, obj);
                    break;
                case "Text":
                    entities ~= createLabel(name, obj);
                    break;
                case "Entity":
                    entities ~= createEntity!(Additional)(name, obj);
                    break;
                case "RenderTarget":
                    targetList[name] = target = createTarget(obj);
                    break;
                default:
                    assert(false, format!"Unknown type '%s'"(type));
            }
        }
        if (templateType.isJust) {
            Renderer renderer;
            switch (templateType.get()) {
                case "2D":
                    assert(camera.isNone, "template '2D' cannot have Camera");
                    renderer = createRenderer2D(world, target);
                    camera = Just(world.camera);
                    break;
                case "3D":
                    assert(camera.isJust, "template '3D' requires any camera");
                    renderer = createRenderer3D(world, camera.get(), target);
                    break;
                default:
                    assert(false, format!"Unknown template type '%s'"(templateType));
            }
            rendererList[world] = renderer;
        } else if (camera.isJust) {
            world.setCamera(camera.get());
        }
        assert(camera.isJust, "camera is not defined");
        foreach (entity; entities) {
            world.add(entity);
        }
    }

    private Camera createPerspectiveCamera(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto camera = new PerspectiveCamera();
        camera.name = name;
        camera.aspectWperH = Core().getWindow().width / Core().getWindow().height;
        auto control = param.fetch!(bool)("control").getOrElse(false);

        alias PerspectiveCameraParamList = DefineParamList!(
            Param!("fovy", Degree, true),
            Param!("nearZ", float, true),
            Param!("farZ", float, true),
            Param!("aspectWperH", float, false),
            ObjectParamList
        );
        setParameter!(
            ParamList!(
                PerspectiveCamera,
                PerspectiveCameraParamList
            )
        )(camera, param);

        if (control) {
            CameraControl.attach(camera);
        }
        return camera;
    }

    private Camera createPixelCamera(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto camera = new PixelCamera();
        camera.name = name;

        alias PixelCameraParamList = DefineParamList!(
            ObjectParamList
        );
        setParameter!(
            ParamList!(
                PixelCamera,
                PixelCameraParamList
            )
        )(camera, param);
        return camera;
    }

    private IRenderTarget createTarget(JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto result = new RenderTarget(Core().getWindow().width, Core().getWindow().height);
        param.fetch!(JSONValue[string])("color").apply!((color) {
            auto type = color.fetch!string("type").getOrElse("uint");
            auto object = color.fetch!string("object").getOrError("'color' must have 'object' as string");
            getAttachFunc(result, type, object)(FramebufferAttachType.Color0);
            color.fetch!vec4("clear").apply!((vec4 clear) => result.setClearColor(clear));
        });
        param.fetch!(JSONValue[string])("depth").apply!((depth) {
            auto type = depth.fetch!string("type").getOrElse("uint");
            auto object = depth.fetch!string("object").getOrError("'depth' must have 'object' as string");
            getAttachFunc(result, type, object)(FramebufferAttachType.Depth);
        });
        param.fetch!(JSONValue[string])("stencil").apply!((stencil) {
            auto type = stencil.fetch!string("type").getOrElse("uint");
            auto object = stencil.fetch!string("object").getOrError("'stencil' must have 'object' as string");
            getAttachFunc(result, type, object)(FramebufferAttachType.Stencil);
        });
        return result;
    }
    private PointLight createPointLight(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto light = new PointLight();
        light.name = name;

        alias PointLightParamList = DefineParamList!(
            Param!("diffuse", vec3, true),
            ObjectParamList
        );
        setParameter!(
            ParamList!(
                PointLight,
                PointLightParamList
            )
        )(light, param);
        return light;
    }

    private Entity createModel(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto path = ModelPath(param.fetch!string("path")
                .getOrError("'Model' must have path as a string"));
        auto material = param.fetch!bool("material").getOrElse(true);
        auto normal = param.fetch!bool("normal").getOrElse(true);
        auto uv = param.fetch!bool("uv").getOrElse(true);
        auto model = XLoader().load(path, material, normal, uv).buildEntity();
        model.name = name;

        alias ModelParamList = DefineParamList!(
            ObjectParamList
        );
        setParameter!(
            ParamList!(
                Entity,
                ModelParamList
            )
        )(model, param);
        return model;
    }

    private Label createLabel(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto pos = param.fetch!vec3("pos").getOrElse(vec3(0));
        LabelFactory factory;

        alias LabelParamList = DefineParamList!(
            Param!("fontName", string, false),
            Param!("text", dstring, false),
            Param!("height", float, false),
            Param!("fontResolution", int, false),
            Param!("wrapWidth", float, false),
            Param!("textColor", vec4, false),
            Param!("backColor", vec4, false),
        );
        setParameter!(
            ParamList!(
                LabelFactory,
                LabelParamList
            )
        )(factory, param);
        auto label = factory.make();
        label.name = name;
        label.pos = pos;
        return label;
    }

    private Entity createEntity(Additional...)(string name, JSONValue[string] param) {
        scope(exit) ensureConsume(param);

        auto geometry = param.fetch!string("geometry")
            .getOrError("Entity must have 'geometry' as string");
        auto material = param.fetch!string("material")
            .getOrError("Entity must have 'material' as string");

        alias getList(T) = T.List;

        import std.traits;
        alias Geoms = staticMap!(getList, DefaultGeometryList, Filter!(ApplyLeft!(isInstanceOf, GeometryList), Additional));
        alias Matls = staticMap!(getList, DefaultMaterialList, Filter!(ApplyLeft!(isInstanceOf, MaterialList), Additional));

        static foreach(Geom; Geoms) {
            if (Geom.Name == geometry) {
                static foreach (Mat; Matls) {
                    if (Mat.Name == material) {
                        auto entity = makeEntity(Geom.Type.create(), new Mat.Type);
                        entity.name = name;
                        setParameter!(
                            ParamList!(
                                typeof(entity),
                                Geom.Params,
                                Mat.Params,
                                ConfigParamList,
                                ObjectParamList
                            )
                        )(entity, param);
                        return entity;
                    }
                }
                assert(false, format!"Unknown material name '%s'"(material));
            }
        }
        assert(false, format!"Unknown geometry name '%s'"(geometry));
    }

    private auto createCommand(JSONValue command) {
        switch (command.type) {
            case JSON_TYPE.STRING:
                return getCommand(parseJSON(format!q{{"type" : "%s"}}(command.str())).object());
            case JSON_TYPE.OBJECT:
                return getCommand(command.object());
            default:
                assert(false, "Key Command's value must be string or object");
        }
    }

    private void delegate(FramebufferAttachType) getAttachFunc(RenderTarget target, string type, string object) {
        import std.meta : AliasSeq;
        import std.string : capitalize;

        void delegate(FramebufferAttachType) func;
        switch (object) {
            static foreach (Func; AliasSeq!("texture", "renderbuffer")) {
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

    private auto getCommand(JSONValue[string] obj) {
        auto type = obj.fetch!(string)("type")
            .getOrError("command must have paramter 'type' as string");
        switch (type) {
            case "End":
                return &Core().end;
            case "ScreenShot":
                auto path = obj.fetch!(string)("path").getOrElse("ScreenShot.png");
                return { screenShot(path); };
            case "ToggleFullScreen":
                return &Core().getWindow().toggleFullScreen;
            case "Clear":
                auto target = obj.fetch!(string)("target")
                    .getOrElse("Screen");
                auto bit = obj.fetch!(BufferBit[])("bits")
                    .getOrElse([BufferBit.Color, BufferBit.Depth, BufferBit.Stencil]);
                return {
                    targetList.at(target)
                        .getOrError(format!"There is no target '%s'"(target))
                        .clear(bit);
                };
            case "Render":
                auto target = obj.fetch!(string)("target");
                return {
                    auto world = target
                        .fmap!(name => worldList.at(name).getOrError(format!"There is no world '%s'"(name)))
                        .getOrElse(worldList.values.wrapRange().getOrError("There are no worlds"));
                    auto renderer = this.rendererList.at(world)
                        .getOrError("There are no renderer");
                    renderer.render();
                };
            case "Blit":
                auto from = obj.fetch!(string)("from")
                    .getOrError("Command 'Blit' must have 'from'");
                auto to = obj.fetch!(string)("to")
                    .getOrError("Command 'Blit' must have 'to'");
                auto bit = obj.fetch!(BufferBit[])("bits")
                    .getOrElse([BufferBit.Color, BufferBit.Depth, BufferBit.Stencil]);
                return {
                    auto src = this.targetList.at(from)
                        .getOrError(format!"There is no target '%s'"(from));
                    auto dst = this.targetList.at(to)
                        .getOrError(format!"There is no target '%s'"(to));
                    src.blitsTo(dst, bit);
                };
            default:
                assert(false, format!"'%s' is not a valid command name"(type));
        }
    }
}

private struct Param(string name, type, bool necessary) {
    alias Name = name;
    alias Type = type;
    alias Necessary = necessary;
}

private struct ParamList(type, params...) {
    alias Type = type;
    enum Name = type.stringof;
    alias Params = params;
}

private struct ParamList(type, string name, params...) {
    alias Type = type;
    enum Name = name;
    alias Params = params;
}

private void setParameter(ParamList)(ref ParamList.Type entity, JSONValue[string] params) {
    static foreach (Param; ParamList.Params) {
        setParameter!(Param.Name, Param.Type, Param.Necessary)(entity, params);
    }
}

private void setParameter(string paramName, ParamType, bool necessary, E)(ref E target, JSONValue[string] params) {
    auto value = params.fetch!ParamType(paramName);
    if (value.isNone) {
        static if (necessary) assert(false, format!"'%s' must have '%s' as '%s'"(target.name, paramName, ParamType.stringof));
        else return;
    }
    mixin("target."~paramName) = value.get();
}

struct GeometryList(Geoms...) { alias List = AliasSeq!(Geoms); }
struct MaterialList(Mats...) { alias List = AliasSeq!(Mats); }

alias DefineGeometryList = GeometryList;
alias DefineMaterialList = MaterialList;
alias DefineParamList = AliasSeq;

alias DefineGeometry = ParamList;
alias DefineMaterial = ParamList;

private void ensureConsume(JSONValue[string] params) {
    import std.range;
    assert(params.empty, format!"Unknown Parameters: '%s'"(params.keys.join(", ")));
}

private auto fetch(JSONValue[string] object, string key) {
    auto result = object.at(key);
    if (result.isJust) object.remove(key);
    return result;
}

private auto fetch(Type)(JSONValue[string] object, string key) {
    auto result = object.at(key).fmapAnd!((JSONValue v) => wrapException!(() => v.as!Type));
    if (result.isJust) object.remove(key);
    return result;
}

private mixin template Dispatch(string[][string] dispatchList) {
    auto opDispatch(string mem, Args...)(auto ref Args args) {
        import std.meta;
        enum OK(string f) = is(typeof(mixin(f~"(args)")));
        static foreach (c; dispatchList[mem]) {{
            static if (OK!(c)) return mixin(c~"(args)");
        }}
    }
}
