module sbylib.core.Core;

import std.datetime;
import core.thread;
import derelict.sdl2.sdl;
import sbylib.core;
import sbylib.camera;
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

    Window window; //現在のウインドウ
    World world;
    private FpsBalancer fpsBalancer;
    private Process[] processes;

    //初期化関数
    this() {
        this.window = new Window("Window Title", 800, 600);
        this.fpsBalancer = new FpsBalancer(60);
    }

    void start() {
        writeln("APPLICATION STARTED");
        //各種初期化
        ShaderStore.init;
        initFunctions();

        mainLoop();
    }

    Process addProcess(const void delegate(Process) func) {
        auto proc = new Process(func);
        this.processes ~= proc;
        return proc;
    }

    //メインループ
    private void mainLoop() {
        import std.stdio;
        import sbylib;
        auto vbo = new VertexBuffer;
        vbo.sendData([
                 -1.0f, -1.0f, 0.0f,
                1.0f, -1.0f, 0.0f,
                0.0f,  1.0f, 0.0f
                ], BufferUsage.Static);
        //auto vert = new Shader("
        //#version 400
        //in vec2 pos;
        //void main() {
        //   gl_Position = vec4(pos, 0, 1);
        //}
        //", ShaderType.Vertex);
        //auto frag = new Shader("
        //#version 400
        //out vec4 color;
        //void main() {
        //color = vec4(1);
        //}", ShaderType.Fragment);
        //auto program = new ShaderProgram([vert, frag]);
        //program.attachAttribute(Attribute(2, "pos"), vbo);
        this.fpsBalancer.loop(() {
            //this.processes = this.processes.filter!(proc => proc.step).array;
            clearColor(vec4(0,.5,.5,1));
            clear(ClearMode.Color, ClearMode.Depth);
            import derelict.opengl;
            glEnableVertexAttribArray(0);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
            drawArrays(Prim.Triangle, 0, 3);
                glDisableVertexAttribArray(0);
            //this.world.render();
            this.window.swapBuffers();
            this.window.pollEvents();
            return window.shouldClose();
        });
        //後始末
        GLFW.terminate();
        AL.terminate();
    }
}
