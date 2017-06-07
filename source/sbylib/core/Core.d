module sbylib.core.Core;

import std.datetime;
import core.thread;
import derelict.opengl;
import derelict.glfw3.glfw3;
import derelict.freetype.ft;
import derelict.freeimage.freeimage;
import derelict.sdl2.sdl;
import derelict.openal.al;
import derelict.alure.alure;
import sbylib.core;
import sbylib.camera;
import sbylib.character;
import sbylib.al;
import sbylib.gl;
import sbylib.input;
import sbylib.shadertemplates;
import sbylib.utils;
import sbylib.setting;
import sbylib.loader;
static import std.file, std.path;
import std.stdio, std.string;

/*
   SbyLibを動かすための準備をするクラスです。
   SbyWorld.init(time);で初期化します。timeは1フレームにかかる時間です。
 */

class SbyWorld {
    static this() {
        /*
        string path = std.file.thisExePath();
        string base = std.path.baseName(path);
        rootPath = path[0..(path.length-base.length)];
        // for DEBUG (生成されたexeのいるフォルダの上の階層にあるResourceとShaderを参照します)
        // VisualStudioではDebugフォルダに生成されるためそれに合わせています
        // 他の方法で生成する場合は階層を1つずらすようにお願いします
        rootPath = rootPath[0..(rootPath.length-1)];
        string sep = std.path.dirSeparator;
        string[] tmp = rootPath.split(sep);
        tmp[tmp.length-1] = "";
        rootPath = tmp.join(sep);
*/
        // for DEBUG ここまで

        DerelictGL3.load();
        DerelictGLFW3.load(GLFW_DLL_PATH);
        DerelictFT.load(FREETYPE_DLL_PATH);
        DerelictFI.load(FREEIMAGE_DLL_PATH);
        DerelictSDL2.load(SDL2_DLL_PATH);
        DerelictAL.load();
        DerelictALURE.load(ALURE_DLL_PATH);

        Window.init();
        FontLoader.init();
        AudioStore.init();
        JoyStick.init();
    }

    Window currentWindow; //現在のウインドウ
    Camera currentCamera; //現在のカメラ
    Font currentFont;     //現在のフォント
    long currentFrameTime; //milliseconds
    float fps; //FPS
    Texture backBuffer; //バックバッファ

    //初期化関数
    this() {
    }

    void setFPS(float fps) {
        this.fps = fps;
        this.currentFrameTime = cast(long)(1000 / fps);
    }

    void start() {
        writeln("APPLICATION STARTED");
        //ウインドウを作成(内部でOpenGLの初期化も行われる)
        currentWindow = new Window("Window Title", 800, 600);
        //各種初期化
        ShaderStore.init;
        initFunctions();

        backBuffer = new Texture(currentWindow.width, currentWindow.height, ImageType.Depth);

        mainLoop();
    }

    //メインループ
    private void mainLoop() {
        StopWatch sw;
        sw.start();
        StopWatch sw2;
        while (!currentWindow.shouldClose)
            {
            sw2.start;
            //バッファを更新
            currentWindow.swapBuffers();
            //イベントをさばく
            currentWindow.pollEvents();
            auto period = sw.peek().msecs();
            if (currentFrameTime > period)
                Thread.sleep(dur!("msecs")(currentFrameTime - period));
            sw.start();
            stdout.flush();
        }
        //後始末
        glfwTerminate();
        //alureShutdownDevice();
    }
}

