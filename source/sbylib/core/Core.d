module sbylib.core.Core;

import std.datetime;
import core.thread;
import sbylib.core;
import sbylib.camera;
import sbylib.constant.ConstantManager;
import sbylib.input;
import sbylib.shadertemplates;
import sbylib.utils;
import sbylib.wrapper.al.AL;
import sbylib.wrapper.gl.GL;
import sbylib.wrapper.glfw.GLFW;
import sbylib.wrapper.freetype.FreeType;
import sbylib.wrapper.freeimage.FreeImage;
import sbylib.wrapper.glfw.Window;
import sbylib.wrapper.freetype.Font;
import sbylib.utils.FpsBalancer;
import sbylib.utils.Array;
import sbylib.core.Process;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;
static import std.file, std.path;
import std.stdio, std.string;
import std.algorithm;
import std.array;
import std.stdio;

/*
   SbyLibを動かすための準備をするクラスです。
   SbyCore.init(time);で初期化します。timeは1フレームにかかる時間です。
 */

class Core {

    mixin Utils.singleton;

    static class Config {
        uint windowWidth;
        uint windowHeight;
        float fps;
    }
    private static Config _config;

    public static Config config() @property {
        assert(_config !is null, "You can configure only before first acquire of Core.");
        return _config;
    }

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
        _config = new Config;
        _config.windowWidth = 800;
        _config.windowHeight = 600;
        _config.fps = 60;
    }

    private Window window; //現在のウインドウ
    private Key key;
    private Mouse mouse;
    private JoyStick joy;
    private Clipboard clipboard;
    private FpsBalancer fpsBalancer;
    private Array!Process processes;
    private bool endFlag;

    //初期化関数
    private this() {
        //AL.init();
        GL.init();
        GLFW.init();
        FreeType.init();
        FreeImage.init();
        ConstantManager.init();
        this.window = new Window("Window Title", config.windowWidth, config.windowHeight);
        this.key = new Key(this.window);
        this.mouse = new Mouse(this.window);
        this.joy = new JoyStick();
        this.clipboard = new Clipboard(this.window);
        this.fpsBalancer = new FpsBalancer(config.fps);
        this.processes = Array!Process(0);

        _config = null;
    }

    ~this() {
        //後始末
        GLFW.terminate();
        //AL.terminate();
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

    Process addProcess(const void delegate() func, string name) {
        return this.addProcess((Process proc) {
            func();
        }, name);
    }

    Process addProcess(const void function() func, string name) {
        return this.addProcess((Process proc) {
            func();
        }, name);
    }

    //メインループ
    private void mainLoop() {
        this.fpsBalancer.loop({
            this.key.update();
            this.mouse.update();
            this.joy.update();
            this.processes.filter!("a.step");
            this.window.swapBuffers();
            this.window.pollEvents();
            stdout.flush();
            return window.shouldClose() || endFlag;
        });
        this.processes.destroy();
    }

    Window getWindow() {
        return this.window;
    }

    Key getKey() {
        return this.key;
    }

    Mouse getMouse() {
        return this.mouse;
    }

    JoyStick getJoyStick() {
        return this.joy;
    }

    Clipboard getClipboard() {
        return this.clipboard;
    }
}
