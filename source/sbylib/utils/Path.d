module sbylib.utils.Path;

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

private mixin template CreatePath(string prefix) {
    private string _path;

    this(string path) {
        this._path = prefix ~ path;
    }

    string getPath() {
        return _path;
    }

    alias getPath this;
}

struct GeneralPath { mixin CreatePath!("./"); }
struct ResourcePath { mixin CreatePath!("./Resource/"); }
struct DllPath { mixin CreatePath!("../dll/"); }
struct ImagePath { mixin CreatePath!("./Resource/image/"); }
struct FontPath { mixin CreatePath!("./Resource/font/"); }
struct ModelPath { mixin CreatePath!("./Resource/model/"); }
struct ConfigPath { mixin CreatePath!("./Resource/config/"); }
