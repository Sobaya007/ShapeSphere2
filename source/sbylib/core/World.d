module sbylib.core.World;

import std.datetime;
import core.thread;
import derelict.opengl;
import derelict.glfw3.glfw3;
import sbylib.core;
import sbylib.camera;
import sbylib.character;
import sbylib.gl;
import sbylib.input;
import sbylib.shadertemplates;
import sbylib.entity;
import sbylib.utils;
static import std.file, std.path;
import std.stdio, std.string;

/*
   SbyLibを動かすための準備をするクラスです。
   SbyWorld.init(time);で初期化します。timeは1フレームにかかる時間です。
 */

class SbyWorld {

    static this() {
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
        writeln(rootPath);
        version(Windows) {
            rootPath = "./";
        }
        // for DEBUG ここまで
        DerelictGL3.load();
        DerelictGLFW3.load("../dll/glfw3.dll");

        glfwSetErrorCallback(&errorCallBack);
        if (!glfwInit()) {
            writeln("Failed to initialize GLFW");
        }
    }

    private {
        this(){}
        extern(C) void errorCallBack(int error, const(char)* description) nothrow {
            printf("description: %.*s\n", description);
            assert(false, "GLFW error");
        }
    }

static:

    Window currentWindow; //現在のウインドウ
    Camera currentCamera; //現在のカメラ
    Font currentFont;     //現在のフォント
    long currentFrameTime; //milliseconds
    float fps; //FPS
    TextureObject backBuffer; //バックバッファ
    string rootPath;

    //初期化関数
    void init(long frameTime) {
        writeln();
        writeln("APPLICATION STARTED");
        //代入
        currentFrameTime = frameTime;
        //ウインドウを作成(内部でOpenGLの初期化も行われる)
        currentWindow = new Window("Window Title", 800, 600);
        //各種初期化
        ShaderStore.init;
        initFunctions();
        //OpenGL関連の初期化
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        backBuffer = new TextureObject(currentWindow.width, currentWindow.height, ImageType.Depth);
    }

    //メインループ
    void mainLoop() {
        StopWatch sw;
        sw.start();
        StopWatch sw2;
        while (!currentWindow.shouldClose)
            {
            sw2.start;
            //Entityを動かす
            StepManager.stepAll();
            //バッファを更新
            currentWindow.swapBuffers();
            //イベントをさばく
            Input.pollEvents();
            if (Input.pressed(KeyButton.Escape)) break;
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

