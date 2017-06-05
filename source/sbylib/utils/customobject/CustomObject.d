module sbylib.utils.customobject.CustomObject;

import sbylib.gl;
import sbylib.math;
import derelict.opengl;
import sbylib.utils.customobject.TexInfo;
import sbylib.utils.customobject.Uniform;
import sbylib.utils.customobject.UniformMatrix;
import sbylib.utils.customobject.UniformValue;
import std.typecons, std.string, std.conv;

/*
   使い方:

   準備:
   ①コンストラクタで初期化
   ②beginMeshでメッシュの構築を開始
   ②addAttributeを任意の回数行う
   ③setIndexで頂点データの並び順を指定
   ④endMeshでメッシュの構築を終了
   使用:
   drawで描画

   データの変更:
   addAttributeで指定した名前を使ってupdate
   getDrawInfoでDrawInfoを取得、setUniformなどでuniformは書き換え可能

   例: 三角ポリゴンの場合

//===============準備===============
float[] vertex = [
0,0,0, //１つ目の頂点
1,0,0, //２つ目の頂点
0,1,0  //３つ目の頂点
];
float[] normal = [
0,0,1, //１つ目の法線
0,0,1, //２つ目の法線
0,0,1  //３つ目の法線
];
uint[] index = [0,1,2];
Material mat = Material.getDefaultMaterial();
CustomObject custom = CustomObject(mat, VAO.Type.Triangle);
custom.beginMesh();
custom.addAttribute!(3, "mVertex")(vertex, VBO.Frequency.Static);
custom.addAttribute!(2, "mNormal")(normal, VBO.Frequency.Static);
custom.setIndex(index, IBO.Frequency.Static);
custom.endMesh();

//※コンストラクタでTypeを指定しないと、beginMeshでTypeを指定しないときエラーになります。
//コンストラクタで指定したTypeを基本的に使用し、beginMeshでTypeを指定した場合にはそれを優先的に使用します。
//beginMeshでメッシュに名前をつけることができます。

//updateについて
//名前をつけたメッシュに対してはその名前を指定します。
//名前をつけていないメッシュが複数ある場合、名前をつけていないメッシュの更新は行えません。
//名前をつけていないメッシュが１つしかない場合、名前を指定しないことでそのメッシュの更新が行えます。

//===========データの変更===========
float[] vertex2 = [
0,0,1, //１つ目の頂点
1,0,1, //２つ目の頂点
0,1,1  //３つ目の頂点
];
custom.update("mVertex", vertex2);

//===============使用===============
custom.draw();
 */

alias DrawMethod = void delegate(CustomObject, RenderConfig, void delegate());

class CustomObject {

private:
    VAO vao;
    VBO[string] vboList;
    IBO ibo;
    TexInfo[10] texIDs;
    Uniform[string] uniformApply;
    Tuple!(float[] delegate(), Uniform)[] dynamicUniformList;
    void delegate() drawFunc;
    public DrawMethod drawMethod;
    ShaderProgram shader;
    bool settingFlag;

    //Attributeの設定を実行する
    void attribute(int num, string name)() {
        //頂点シェーダのattribute変数のアドレスを取得
        int vLoc = glGetAttribLocation(shader.programID, name.toStringz);
        //assert(vLoc != -1, name ~ " is not found or used in shader."); 
        glEnableVertexAttribArray(vLoc);
        //さっきのところをmVertexってことにする
        glVertexAttribPointer(vLoc, num, GL_FLOAT, GL_FALSE, num * float.sizeof, null);
    }

    //Uniformの設定を実行する
    void uniform() {
        foreach (unit; 0..texIDs.length) {
            if (texIDs[unit] is null) continue;
            glActiveTexture(GL_TEXTURE0 + cast(int)unit);
            glBindTexture(GL_TEXTURE_2D, texIDs[unit].id);
            glUniform1i(texIDs[unit].sLoc, cast(int)unit);
        }
        foreach (t; dynamicUniformList) {
            auto data = t[0]();
            assert(t[1].arguments.length == data.length, "Different Length Of Data Provided by Dynamic Uniform.\n Necessary length is " ~ to!string(t[1].arguments.length) ~ ", But Provided Length is " ~ to!string(data.length));
            foreach (i, ref e; t[1].arguments) {
                e = data[i];
            }
        }
        foreach (k, u; uniformApply) {
            assert(u.arguments, k ~ "'s argument is null");
            u.apply;
        }
    }

    //Uniformの準備をする
    void prepareUniform(uint num, string name)() {
        auto uni = new UniformValue!(num)(shader, name);
        uni.arguments = new float[num];
        uniformApply[name] = uni;
    }

    void prepareUniformMatrix(uint num, string name)() {
        auto uni = new UniformMatrix!(num)(shader, name);
        uni.arguments = new float[num^^2];
        uniformApply[name] = uni;
    }
    void prepareUniform(uint num)(string name) {
        auto uni = new UniformValue!(num)(shader, name);
        uni.arguments = new float[num];
        uniformApply[name] = uni;
    }

    void prepareUniformMatrix(uint num)(string name) {
        auto uni = new UniformMatrix!(num)(shader, name);
        uni.arguments = new float[num^^2];
        uniformApply[name] = uni;
    }
public:

    this(ShaderProgram shader, Prim type) {
        this.drawMethod = (c, r, u) {
            r.defaulting();
            u();
        };
        this.shader = shader;
        this.vao = new VAO(type);
        drawFunc = {
            uniform();
            vao.draw(ibo);
        };
    }

    void beginMesh() {
        vao.bind;
        settingFlag = true;
    }

    void endMesh() {
        vao.unBind;
        settingFlag = false;
    }

    void addAttribute(int dimension, string name)(Vector!(float, dimension)[] data, GpuSendFrequency freq) {
        float[] dataArray;
        dataArray.length = data.length * dimension;
        foreach (i; 0..data.length)
            dataArray[i*dimension..(i+1)*dimension] = data[i].array;
        addAttribute!(dimension, name)(dataArray, freq);
    }

    void addAttribute(int dimension, string name)(float[] data, GpuSendFrequency freq) in {
        assert(settingFlag, "Please Call this Function between 'beginMesh' and 'endMesh'");
    } body {
        auto vbo = new VBO(data, freq);
        vbo.bind();
        attribute!(dimension, name)();
        vbo.unBind();

        vboList[name] = vbo;
    }

    void setIndex(uint[] data, GpuSendFrequency freq)  in {
        assert(settingFlag, "Please Call this Function between 'beginMesh' and 'endMesh'");
    } body {
        ibo = new IBO(data, freq);
    }

    void draw() in {
        assert(drawMethod, "drawMethod must not be null.");
    } body {
        shader.use();
        vao.bind(); {
            ibo.bind(); {
                static RenderConfig rc;
                drawMethod(this, rc, drawFunc);
            } ibo.unBind();
        } vao.unBind();
    }

    void update(string name, float[] data) in {
        assert(name in vboList, name ~ " is not found");
    } body {
        vboList[name].update(data);
    }

    void addDynamicUniform(uint num, string name)(float delegate() newDynamicUniform) {
        addDynamicUniform!(num, name)([newDynamicUniform()]);
    }

    void addDynamicUniform(uint num, string name)(float[] delegate() newDynamicUniform) {
        if ((name in uniformApply ) is null) prepareUniform!(num, name)();
        this.dynamicUniformList ~= tuple(newDynamicUniform, uniformApply[name]);
    }

    void addDynamicUniformMatrix(uint num, string name)(float[] delegate() newDynamicUniform) {
        if ((name in uniformApply ) is null) prepareUniformMatrix!(num, name)();
        this.dynamicUniformList ~= tuple(newDynamicUniform, uniformApply[name]);
    }

    void setTexture(TextureObject texObj, string locationName = "mTexture", int textureUnit = 0) {
        setTexture(texObj.texID, locationName, textureUnit);
    }

    void setTexture(uint texID, string locationName = "mTexture", int textureUnit = 0) {
        int sLoc = glGetUniformLocation(shader.programID, locationName.toStringz);

        texIDs[textureUnit] = new TexInfo(texID, sLoc);
    }

    //たぶんこっちのほうが下のより速い
    void setUniform(uint num, string name)(float[] uniform...) {
        if ((name in uniformApply) is null) {
            prepareUniform!(num, name)();
        }
        auto array = uniformApply[name].arguments;
        foreach (i; 0..uniform.length) array[i] = uniform[i];
    }

    void setUniformMatrix(uint num, string name)(float[] uniform) {
        if ((name in uniformApply) is null) {
            prepareUniformMatrix!(num, name)();
        }
        auto array = uniformApply[name].arguments;
        foreach (i; 0..uniform.length) array[i] = uniform[i];
    }

    //たぶんこっちのほうが上のより遅い
    void setUniform(uint num)(string name, float[] uniform...) {
        if ((name in uniformApply) is null) {
            prepareUniform!(num)(name);
        }
        auto array = uniformApply[name].arguments;
        foreach (i; 0..uniform.length) array[i] = uniform[i];
    }

    void setUniformMatrix(uint num)(string name, float[] uniform) {
        if ((name in uniformApply) is null) {
            prepareUniformMatrix!(num)(name);
        }
        auto array = uniformApply[name].arguments;
        foreach (i; 0..uniform.length) array[i] = uniform[i];
    }

    void setShaderProgram(ShaderProgram shader) {
        this.shader = shader;
    }

    float[] getUniform(string name)() {
        return uniformApply[name].arguments;
    }
}
