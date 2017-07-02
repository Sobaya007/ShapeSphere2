module sbylib.core.Core;

import std.datetime;
import core.thread;
import derelict.sdl2.sdl;
import sbylib.core;
import sbylib.camera;
import sbylib.constant.ConstantManager;
import sbylib.input;
import sbylib.shadertemplates;
import sbylib.utils;
import sbylib.setting;
import sbylib.wrapper.al.AL;
import sbylib.wrapper.gl.GL;
import sbylib.wrapper.glfw.GLFW;
import sbylib.wrapper.freetype.FreeType;
import sbylib.wrapper.freeimage.FreeImage;
import sbylib.wrapper.glfw.Window;
import sbylib.wrapper.freetype.Font;
import sbylib.utils.FpsBalancer;
import sbylib.core.Process;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;
static import std.file, std.path;
import std.stdio, std.string;
import std.algorithm;
import std.array;

/*
   SbyLibを動かすための準備をするクラスです。
   SbyCore.init(time);で初期化します。timeは1フレームにかかる時間です。
 */

class Core {
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

        DerelictSDL2.load(SDL2_DLL_PATH);

        AL.init();
        GL.init();
        GLFW.init();
        FreeType.init();
        FreeImage.init();
        JoyStick.init();
    }

    private Window window; //現在のウインドウ
    private FpsBalancer fpsBalancer;
    private Process[] processes;
    private bool endFlag;

    //初期化関数
    this() {
        ConstantManager.init();
        this.window = new Window("Window Title", 800, 600);
        this.fpsBalancer = new FpsBalancer(60);
    }

    ~this() {
        //後始末
        //GLFW.terminate();
        AL.terminate();
    }

    void start() {
        writeln("APPLICATION STARTED");
        //各種初期化

        mainLoop();
    }

    void end() {
        this.endFlag = true;
    }

    Process addProcess(const void delegate(Process) func, string name) {
        auto proc = new Process(func, name);
        this.processes ~= proc;
        return proc;
    }

    //メインループ
    private void mainLoop() {
        this.fpsBalancer.loop({
            clearColor(vec4(0,.5,.5,1));
            clear(ClearMode.Color, ClearMode.Depth);
            this.processes = this.processes.filter!(proc => proc.step).array;
            this.window.swapBuffers();
            this.window.pollEvents();
            return window.shouldClose() || endFlag;
        });
    }

    Window getWindow() {
        return this.window;
    }

    alias getWindow this;
}
