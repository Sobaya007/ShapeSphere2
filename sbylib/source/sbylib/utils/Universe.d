module sbylib.utils.Universe;

import std.json;
import std.format;
import sbylib;
import std.stdio;
import std.meta;
import std.typecons;

class Universe {

    alias CameraSetCallback = void delegate(Camera);
    alias Command = void delegate();

    private World[string] worldList;
    private IRenderTarget[string] targetList;
    private Renderer[World] rendererList;
    private Window[string] windowList;

    private ProcessManager mProcess;
    private Key mKey;
    private Mouse mMouse;
    private JoyStick mJoy;
    private Maybe!Process thisUpdate;

    private CameraSetCallback[][World] cameraSetCallbackList;

    private bool isCoreUniverse;

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

    this(bool isCoreUniverse = false) {
        this.isCoreUniverse = isCoreUniverse;
    }

    package(sbylib) void update() {
        this.joy.update();
        this.process.update();
    }

    void destroy() {
        foreach (name, world; worldList) world.destroy();
        thisUpdate.kill();
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

    Maybe!(Renderer) findRendererByWorld(World world) {
        return rendererList.at(world);
    }

    private Key key() {
        if (mKey is null) {
            this.mKey = new Key(Core().getWindow());
            this.addProcess(&mKey.update, "key.update");
        }
        return mKey;
    }

    private Mouse mouse() {
        if (mMouse is null) {
            this.mMouse = new Mouse(Core().getWindow());
            this.addProcess(&mMouse.update, "mouse.update");
        }
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

        targetList["Screen"] = Core().getWindow().getScreen(); //for Core Implementation, initialization is placed here.

        import std.file;

        auto root = wrapException(parseJSON(readText(path)).as!(JSONValue[string]))
            .getOrError("root must be object");

        auto keyCommand = root.fetch("KeyCommand");
        auto render = root.fetch("Render");
        auto window = root.fetch("Window");
        auto target = root.fetch("RenderTarget");

        keyCommand.apply!((keyCommand) {
            createKeyCommand(keyCommand.asObject("KeyCommand"));
        });
        window.apply!((window) {
            createWindows(window.asObject("Window"));
        });
        target.apply!((target) {
            createTargets(target.asObject("RenderTarget"));
        });

        foreach (key, value; root) {
            createWorld!(Additional)(key, value.asObject(key));
        }
        if (render.isNone) {
            render = Just(parseJSON(q{
                [
                    {
                        "type" : "Render",
                        "clear" : ["Color", "Depth"]
                    }
                ]
            }));
        }
        render.apply!((render) {
            createRender(render.asArray("Render"));
        });
        if (!this.isCoreUniverse) thisUpdate = Just(Core().addProcess(&update, isCoreUniverse ? "CoreUniverse.update" : "universe.update"));
    }

    private void createKeyCommand(JSONValue[string] commandList) {
        import std.conv;

        foreach (key, command; commandList) {
            auto button = wrapException(key.to!KeyButton)
                .getOrError(format!"'%s' is not a valid key name"(key));

            this.justPressed(button).add(createCommand(command));
        }
    }

    private void createTargets(JSONValue[string] targetList) {
        foreach (name, content; targetList) {
            this.targetList[name] = createTarget(content.asObject(name));
        }
    }

    private void createRender(JSONValue[] array) {
        import std.algorithm : map;
        import std.array;

        auto process = array.map!(v => createCommand(v)).array;
        this.addProcess({ foreach (proc; process) proc();}, "Render");
    }

    private void createWindows(JSONValue[string] obj) {
        foreach (name, content; obj) {
            windowList[name] = createWindow(content.asObject(name));
        }
    }

    private Window createWindow(JSONValue[string] obj) {
        auto screenName = obj.fetch!(string)("screen")
            .getOrElse("Screen");
        auto title = obj.fetch!(string)("title")
            .getOrElse("");
        auto pos = obj.fetch!(vec2)("pos")
            .getOrElse(vec2(100, 50) + vec2(100) * windowList.length);
        auto size = obj.fetch!(vec2)("size")
            .getOrError("Window must have 'size' as vec2");
        Window window;
        if (screenName == "Screen") {
            window = Core().getWindow();
            window.setSize(cast(uint)size.x, cast(uint)size.y);
            window.setTitle(title);
        } else {
            window = new Window(title, cast(uint)size.x, cast(uint)size.y);
        }
        window.pos = cast(vec2i)pos;
        targetList[screenName] = window.getScreen();
        return window;
    }

    private void createWorld(Additional...)(string name, JSONValue[string] worldContent) {

        auto world = new World();
        worldList[name] = world;

        Maybe!Camera camera;
        Entity[] entities;

        foreach (name, content; worldContent) {
            JSONValue[string] obj;
            switch (content.type) {
                case JSON_TYPE.STRING:
                    obj = ["type" : parseJSON(format!q{"%s"}(content.str()))];
                    break;
                case JSON_TYPE.OBJECT:
                    obj = content.object();
                    break;
                default:
                    assert(false, format!"%s's value must be a string or an object"(name));
            }
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
                default:
                    assert(false, format!"Unknown type '%s'"(type));
            }
        }
        cameraSetCallbackList[world] ~= (Camera camera) {
            world.setCamera(camera);
            foreach (entity; entities) {
                world.add(entity);
            }
        };
        camera.apply!((Camera camera) {
            setCamera(world, camera);
        });
    }

    void setCamera(World world, Camera camera) {
        foreach (cb; cameraSetCallbackList[world]) {
            cb(camera);
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
            CameraControl.attach(camera, Core().getWindow());
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
        attach(result, param, "color", FramebufferAttachType.Color0);
        attach(result, param, "color0", FramebufferAttachType.Color0);
        attach(result, param, "color1", FramebufferAttachType.Color1);
        attach(result, param, "color2", FramebufferAttachType.Color2);
        attach(result, param, "depth", FramebufferAttachType.Depth);
        attach(result, param, "stencil", FramebufferAttachType.Stencil);

        return result;
    }

    private void attach(RenderTarget target, JSONValue[string] param, string bufferName, FramebufferAttachType attachType) {
        param.fetch!(JSONValue[string])(bufferName).apply!((buffer) {
            auto type = buffer.fetch!string("type").getOrElse("uint");
            auto object = buffer.fetch!string("object").getOrError(format!"'%s' must have 'object' as string"(bufferName));
            //buffer.fetch!vec4("clear").apply!((vec4 clear) => result.setClearColor(clear));
            getAttachFunc(target, type, object)(attachType);
        });
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
        auto textColor = param.fetch!vec4("textColor").getOrElse(vec4(1));
        auto text = param.fetch!string("text").getOrElse("");
        LabelFactory factory;
        factory.text = text.colored(textColor);

        alias LabelParamList = DefineParamList!(
            Param!("fontName", string, false),
            Param!("height", float, false),
            Param!("fontResolution", int, false),
            Param!("wrapWidth", float, false)
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

    static Entity createEntity(Additional...)(string name, JSONValue[string] param) {
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

    private Command createCommand(JSONValue command) {
        switch (command.type) {
            case JSON_TYPE.STRING:
                return createCommand(parseJSON(format!q{{"type" : "%s"}}(command.str())));
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
            .getOrError("command must have parameter 'type' as string");
        switch (type) {
            case "End":
                return &Core().end;
            case "ScreenShot":
                auto path = obj.fetch!(string)("path").getOrElse("ScreenShot.png");
                return { screenShot(path); };
            case "ToggleFullScreen":
                return &Core().getWindow().toggleFullScreen;
            case "Clear":
                auto target = getTarget(obj.fetch!(string)("target"))
                    .getOrError("'Clear' must have parameter 'target' as string");
                auto bit = obj.fetch!(BufferBit[])("bits")
                    .getOrElse([BufferBit.Color, BufferBit.Depth, BufferBit.Stencil]);
                return {
                    target.clear(bit);
                };
            case "Render":
                auto world = getWorld(obj.fetch!(string)("world"))
                    .getOrError("'Render' must have parameter 'world' as string");
                auto target = getTarget(obj.fetch!(string)("target"))
                    .getOrError("'Render' must have parameter 'target' as string");
                auto viewport = new AspectFixViewport(Core().getWindow());
                auto clear = obj.fetch!(BufferBit[])("clear");
                auto postProcess = obj.fetch!string("postProcess");
                Renderer renderer;
                if (postProcess.isJust) {
                    renderer = new PostProcessRenderer(world, target, viewport, new ComputeProgram(ShaderPath(postProcess.unwrap()~".comp")));
                } else {
                    renderer = new Renderer(world, target, viewport);
                }
                rendererList[world] = renderer;
                return clear.fmap!((BufferBit[] bits) => {
                    target.clear(bits);
                    renderer.renderAll();
                }).getOrElse({
                    renderer.renderAll();
                });
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

    private Maybe!IRenderTarget getTarget(Maybe!string name) {
        return name.fmap!((string name) => Just(targetList.at(name).getOrError(format!"target '%s' is not found"(name))))
            .getOrElse(getDefaultTarget());
    }
 
    private Maybe!World getWorld(Maybe!string name) {
        return name.fmap!((string name) => Just(worldList.at(name).getOrError(format!"world '%s' is not found"(name))))
            .getOrElse(getDefaultWorld());
    }

    private Maybe!World getDefaultWorld() {
        if (worldList.length == 1) return Just(worldList.values[0]);
        return None!(World);
    }

    private Maybe!IRenderTarget getDefaultTarget() {
        if (targetList.length == 1) return Just(targetList.values[0]);
        return None!(IRenderTarget);
    }

    private Maybe!Window getDefaultWindow() {
        if (windowList.length == 0) return Just(Core().getWindow);
        return None!(Window);
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
    mixin("target."~paramName) = value.unwrap();
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
    auto result = object.at(key).fmapAnd!((JSONValue v) => wrapException(v.as!Type));
    if (result.isJust) object.remove(key);
    return result;
}

private auto asObject(JSONValue value, string name) {
    import std.format;
    return wrapException(value.object)
        .getOrError(format!"%s's value must be an object"(name));
}

private auto asArray(JSONValue value, string name) {
    import std.format;
    return wrapException(value.array)
        .getOrError(format!"%s's value must be an array"(name));
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
