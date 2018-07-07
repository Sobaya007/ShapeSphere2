module sbylib.utils.Path;

import sbylib.utils.Maybe;

/*
private {
    enum ROOT_PATH = "./";
    enum DLL_ROOT = "../dll/";
    enum SOURCE_ROOT = "./source/";
    enum RESOURCE_ROOT = "./Resource/";
    enum GLFW_DLL_PATH = DLL_ROOT ~ "glfw3.dll";
    enum FREETYPE_DLL_PATH = DLL_ROOT ~ "freetype.dll";
    enum SDL2_DLL_PATH = DLL_ROOT ~ "SDL2.dll";
    enum AL_DLL_PATH = DLL_ROOT ~ "OpenAl32.dll";
    enum ALURE_DLL_PATH = DLL_ROOT ~ "ALURE32.dll";
    enum FREEIMAGE_DLL_PATH = DLL_ROOT ~ "FreeImage.dll";
    enum TIME_LOG_PATH =  ROOT_PATH ~ "time.log";
}
*/

private mixin template CreatePath(string prefix, bool enableReadLibray) {
    private string _path;

    this(string path, string callerFile = __FILE__) {
        this._path = prefix ~ path;

        static if (enableReadLibray) {
            import std.file : exists;
            import std.algorithm : canFind;
            if (exists(this._path)) return;
            if (!callerFile.canFind("sbylib")) return;
            auto root = findRoot(callerFile);
            if (root.isNone) return;
            this._path = root.unwrap() ~ "/" ~ this._path;
        } }

    string getPath() {
        return _path;
    }

    private Maybe!string findRoot(string thisFile) {
        import std.path : dirName;
        import std.file : exists;
        import std.range : empty;
        auto path = thisFile.dirName;
        while (!exists(path ~ "/dub.sdl")) {
            if (path.empty) return None!string;
            path = path.dirName;
        }
        return Just(path);
    }

    alias getPath this;
}

struct GeneralPath { mixin CreatePath!("./", false); }
struct ResourcePath { mixin CreatePath!("./Resource/", false); }
struct DllPath { mixin CreatePath!("../dll/", false); }
struct ImagePath { mixin CreatePath!("./Resource/image/", false); }
struct FontPath { mixin CreatePath!("./Resource/font/", true); }
struct ModelPath { mixin CreatePath!("./Resource/model/", false); }
struct ConfigPath { mixin CreatePath!("./Resource/config/", false); }
struct ShaderPath { mixin CreatePath!("./Resource/shader/", true); }
