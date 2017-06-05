module sbylib.gl.ShaderProgram;

import sbylib.gl;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;

class ShaderProgram {

    static enum InputType {SourceCode, FilePath}

    uint programID = -1;
    private static uint[string] shaders;

    string vsSource, fsSource, gsSource;
    string vsPath, fsPath, gsPath;

    this(string vs, string fs, InputType inputType) {
        this(vs, fs, null, inputType);
    }

    this(string vs, string fs, string gs, InputType inputType) {
        final switch (inputType) {
        case InputType.SourceCode:
            programID = getShaderProgramIDFromString(vs, fs, gs);
            break;
        case InputType.FilePath:
            this.vsPath = vs;
            this.fsPath = fs;
            this.gsPath = gs;
            programID = getShaderProgramID(vs, fs, gs);
            break;
        }
        if (programID == -1) assert(false);
    }

    ~this() {
        glDeleteProgram(programID);
    }

    void reload() {
        auto tmp = getShaderProgramID(vsPath, fsPath, gsPath);
        if (tmp != -1) programID = tmp;
    }

    void use() @nogc const {
        glUseProgram(programID);
    }

    private int getShaderProgramID(string vsPath, string fsPath, string gsPath) {
        uint *p;
        int vsID, fsID, gsID;
        if ((p = vsPath in shaders) != null) {
            vsID = *p;
        } else {
            auto vsSource = ((cast(const char[])read(vsPath))).idup;
            vsID = getVertexShaderFromString(vsSource);
            if (vsID == -1) return -1;
        }
        if ((p = fsPath in shaders) != null) {
            fsID = *p;
        } else {
            auto fsSource = ((cast(const char[])read(fsPath))).idup;
            fsID = getFragmentShaderFromString(fsSource);
            if (fsID == -1) return -1;
        }
        if (gsPath) {
            if ((p = gsPath in shaders) != null) {
                gsID = *p;
            } else {
                auto gsSource = ((cast(const char[])read(gsPath))).idup;
                gsID = getGeometryShaderFromString(gsSource);
                if (gsID == -1) return -1;
            }
        } else {
            gsID = -1;
        }
        return getSP(vsID, fsID, gsID);
    }

    private int getShaderProgramIDFromString(string vsString, string fsString, string gsString) {
        int vsID = getVertexShaderFromString(vsString);
        int fsID = getFragmentShaderFromString(fsString);
        int gsID;
        if (gsString) gsID = getGeometryShaderFromString(gsString);
        else gsID = -1;
        return getSP(vsID, fsID, gsID);
    }

    private static int getSP(int vsID, int fsID, int gsID) {
        //シェーダプログラムを生成
        int programID = glCreateProgram();

        //シェーダプログラムと各シェーダを紐付け
        glAttachShader(programID, vsID);
        glAttachShader(programID, fsID);
        if (gsID != -1) {
            glAttachShader(programID, gsID);
            //glProgramParameteriEXT(program, GL_GEOMETRY_INPUT_TYPE_EXT, GL_TRIANGLES);
            //glProgramParameteriEXT(program, GL_GEOMETRY_OUTPUT_TYPE_EXT, GL_TRIANGLES);
            //
            //glProgramParameteriEXT(program, GL_GEOMETRY_VERTICES_OUT_EXT, 1024);
        }



        //シェーダプログラムとシェーダをリンク
        glLinkProgram(programID);

        //リンクエラーを確認
        int result;
        glGetProgramiv(programID, GL_LINK_STATUS, &result);
        if (result == GL_FALSE) {
            int logLength;
            glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &logLength);
            char[] log = new char[100];
            int a;
            glGetProgramInfoLog(programID, logLength, &a, log.ptr);
            //assert(false, "Link Error\n" ~ to!string(log));
            writeln("Link Error\n" ~ to!string(log));
            return -1;
        }
        return programID;
    }

    private int getVertexShaderFromString(string vsSource, string vsPath = null) {
        this.vsSource = vsSource;
        uint vsID, fsID;
        vsID = glCreateShader(GL_VERTEX_SHADER);
        auto str = vsSource.toStringz;
        int len = cast(int)vsSource.length;
        glShaderSource(vsID, 1, &str, null);
        glCompileShader(vsID);
        if (vsPath) shaders[vsPath] = vsID;
        int result;
        glGetShaderiv(vsID, GL_COMPILE_STATUS, &result);
        if (result == GL_FALSE) {
            int logLength;
            glGetShaderiv(vsID, GL_INFO_LOG_LENGTH, &logLength);
            char[] log = new char[logLength];
            int a;
            glGetShaderInfoLog(vsID, logLength, &a, &log[0]);
            string errorString = "Compile Error";
            if (vsPath)
                errorString ~= "in \"" ~ vsPath ~ "\".\n";
        else
                errorString ~= ".\n";
            errorString ~= getLogString(to!string(log), vsSource);
            //assert(false, errorString);
            writeln(errorString);
            return -1;
        }
        return vsID;
    }

    private int getFragmentShaderFromString(string fsSource, string fsPath = null) {
        this.fsSource = fsSource;
        int fsID;
        fsID = glCreateShader(GL_FRAGMENT_SHADER);
        auto str = fsSource.toStringz;
        int len = cast(int)fsSource.length;
        glShaderSource(fsID, 1, &str, null);
        glCompileShader(fsID);
        if (fsPath) shaders[fsPath] = fsID;
        int result;
        glGetShaderiv(fsID, GL_COMPILE_STATUS, &result);
        if (result == GL_FALSE) {
            int logLength;
            glGetShaderiv(fsID, GL_INFO_LOG_LENGTH, &logLength);
            char[] log = new char[logLength];
            int a;
            glGetShaderInfoLog(fsID, logLength, &a, log.ptr);
            string errorString = "Compile Error";
            if (fsPath)
                errorString ~= "in \"" ~ fsPath ~ "\".\n";
        else
                errorString ~= ".\n";

            errorString ~= getLogString(to!string(log), fsSource);
            writeln(errorString);
            //assert(false, errorString);
            return -1;
        }
        return fsID;
    }

    private int getGeometryShaderFromString(string gsSource, string gsPath = null) {
        this.gsSource = gsSource;
        int gsID;
        gsID = glCreateShader(GL_GEOMETRY_SHADER);
        auto str = gsSource.toStringz;
        int len = cast(int)gsSource.length;
        glShaderSource(gsID, 1, &str, null);
        glCompileShader(gsID);
        if (gsPath) shaders[gsPath] = gsID;
        int result;
        glGetShaderiv(gsID, GL_COMPILE_STATUS, &result);
        if (result == GL_FALSE) {
            int logLength;
            glGetShaderiv(gsID, GL_INFO_LOG_LENGTH, &logLength);
            char[] log = new char[logLength];
            int a;
            glGetShaderInfoLog(gsID, logLength, &a, log.ptr);
            string errorString = "Compile Error";
            if (gsPath)
                errorString ~= "in \"" ~ gsPath ~ "\".\n";
        else
                errorString ~= ".\n";

            errorString ~= getLogString(to!string(log), gsSource);
            writeln(errorString);
            //assert(false, errorString);
            return -1;
        }
        return gsID;
    }

    private static string getLogString(string log, string sourceCode) {
        auto lines = log.splitLines;
        int[] lineNum;
        foreach (string line; lines) {
            auto strs = split(line, ":");
            if (strs.length > 0 && strs[0] == "ERROR") {
                auto c = strs[1].split[0];
                lineNum ~= to!int(c)-1;
            }
        }
        auto r = assumeSorted(lineNum);
        string result;
        auto strs = sourceCode.splitLines;
        foreach (int i, str; strs) {
            if (r.canFind(i)) {
                result ~= "▶";
                result ~= str;
            } else {
                result ~= str;
            }
            result ~= "\n";
        }
        result ~= log;
        return result;
    }
}
