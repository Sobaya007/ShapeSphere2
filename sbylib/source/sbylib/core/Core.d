module sbylib.core.Core;

import std.datetime;
import core.thread;
import sbylib.core;
import sbylib.camera;
import sbylib.input;
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
import std.concurrency;

/*
   SbyLibを動かすための準備をするクラスです。
   SbyCore.init(time);で初期化します。timeは1フレームにかかる時間です。
 */

class Core {

    mixin Singleton;

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
    private Universe universe;
    private Clipboard clipboard;
    private FpsBalancer fpsBalancer;
    private bool startFlag;
    private bool endFlag;

    //初期化関数
    private this() {
        //AL.init();
        GL.init();
        GLFW.init();
        FreeType.init();
        FreeImage.init();
        this.fpsBalancer = new FpsBalancer(config.fps);
        this.universe = new Universe(true); //notify this universe is special
    }

    ~this() {
        //後始末
        GLFW.terminate();
        //AL.terminate();
    }

    void start() {
        if (startFlag) return; //prevent dual start
        getWindow(); // for initialize window
        writeln("APPLICATION STARTED");
        startFlag = true;

        mainLoop();

        import core.stdc.stdlib;
        exit(0);
    }

    void end() {
        this.endFlag = true;
    }

    //メインループ
    private void mainLoop() {
        this.fpsBalancer.loop({
            this.universe.update();
            stdout.flush();
            return window.shouldClose() || endFlag;
        });
        debug {
            import std.file;
            write("process.log", "");
            this.appendLog();
        }
    }

    Window getWindow() {
        if (this.window is null) {
            this.window = new Window("Window Title", config.windowWidth, config.windowHeight);
            _config = null;
        }
        return this.window;
    }

    Universe getUniverse() {
        return this.universe;
    }

    Clipboard getClipboard() {
        if (this.clipboard is null) {
            this.clipboard = new Clipboard(this.getWindow());
        }
        return this.clipboard;
    }

    alias getUniverse this;
}
