module sbylib.gl.TextureObject;

import derelict.opengl;
import std.stdio, std.string, std.conv;

import sbylib.gl;

class TextureObject {
    import derelict.freeimage.freeimage;

    immutable uint texID;
    private int _width, _height;
    ImageType type;
    bool loaded = false;
    FrameBufferObject writeFbo; // for writeBegin()/writeEnd()
    string path; //nullの場合もあり

    static this() {
        DerelictFI.load("../dll/FreeImage.dll");
    }

    /*
     @params:
     filename = 読み込む画像の名前
   */
    // filenameを受け取って、幅、高さ、GLtexIDを入手すればおｋ
    this(string filename){
        this.path = filename;
        writeln("Target : " ~ filename);
        auto type = FreeImage_GetFileType(filename.toStringz,0);
        if(type == -1){
            writeln("Error : file not found");
            writeln();
            return;
        }
        FIBITMAP* origin = FreeImage_Load(type,filename.toStringz);
        if(!origin){
            writeln("Error : cannot load file");
            writeln();
            return;
        }
        FIBITMAP* bitmap = FreeImage_ConvertTo32Bits(origin);
        _width = FreeImage_GetWidth(bitmap);
        _height = FreeImage_GetHeight(bitmap);
        this.type = ImageType.RGBA;
        writeln("Size (" ~ to!string(_width) ~ "x" ~ to!string(_height) ~ ")");
        uint textureID;
        glGenTextures(1,&textureID);
        texID = textureID;
        glBindTexture(GL_TEXTURE_2D, textureID);

        setMagFilter(TexFilterType.Linear);
        setMinFilter(TexFilterType.Linear);
        setWrapS(TexWrapType.Repeat);
        setWrapT(TexWrapType.Repeat);

        glTexImage2D(GL_TEXTURE_2D, 0, this.type, _width, _height,
                0, GL_BGRA, GL_UNSIGNED_BYTE, FreeImage_GetBits(bitmap));
        FreeImage_Unload(bitmap);
        FreeImage_Unload(origin);
        writeln("successfully loaded.");
        writeln();

        loaded = true;
    }

    /*
     @params:
     _width = テクスチャの幅
     _height = テクスチャの高さ
     texMode = テクスチャの種類(GL_RGBなど)
   */
    this(int _width, int _height, ImageType type) {
        // レンダリングしようとしているテクスチャ
        uint id;
        glGenTextures(1, &id);
        this.texID = id;

        bind();

        // OpenGLに空の画像を与える(最後が"0")
        glTexImage2D(GL_TEXTURE_2D, 0, type, _width, _height, 0, type, GL_UNSIGNED_BYTE, null);

        // フィルタリング
        setMagFilter(TexFilterType.Linear);
        setMinFilter(TexFilterType.Linear);
        setWrapS(TexWrapType.Repeat);
        setWrapT(TexWrapType.Repeat);

        this._width = _width;
        this._height = _height;
        this.type = type;

        unBind();

        loaded = true;
    }

    /*
     @params:
     buffer =　読み込むビットマップ情報
   */
    this(ubyte* buffer, int _width, int _height) {
        uint texID;
        // Generate a new texture
        glGenTextures(1, &texID);
        this.texID = texID;

        // Set texture clamping method
        setWrapS(TexWrapType.ClampToEdge);
        setWrapT(TexWrapType.ClampToEdge);

        // Set texture interpolation method to use linear interpolation (no MIPMAPS)
        setMagFilter(TexFilterType.Linear);
        setMinFilter(TexFilterType.Linear);

        // Specify the texture specification
        glTexImage2D(
                GL_TEXTURE_2D,
                0,          // mipmap
                GL_RGBA,
                _width,          // _width
                _height,          // _height
                0,          // border
                GL_RGBA,
                GL_UNSIGNED_BYTE,
                buffer
                );

        this._width = _width;
        this._height = _height;
        this.type = ImageType.RGBA;

        loaded = true;

    }

    @property uint width() {
        return _width;
    }

    @property uint height() {
        return _height;
    }

    @property void width(uint w) {
        _width = w;
        bind();
        glTexImage2D(
                GL_TEXTURE_2D,
                0,          // mipmap
                type,
                _width,          // _width
                _height,          // _height
                0,          // border
                GL_RGBA,
                GL_UNSIGNED_BYTE,
                null
                );
        unBind();
    }

    @property void height(uint h) {
        _height = h;
        bind();
        glTexImage2D(
                GL_TEXTURE_2D,
                0,          // mipmap
                type,
                _width,          // _width
                _height,          // _height
                0,          // border
                GL_RGBA,
                GL_UNSIGNED_BYTE,
                null
                );
        unBind();
    }
    enum TexFilterType {Linear = GL_LINEAR, Nearest = GL_NEAREST}

    void setMagFilter(TexFilterType type) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, type);
    }

    void setMinFilter(TexFilterType type) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, type);
    }

    enum TexWrapType {
        Repeat = GL_REPEAT,
        ClampToEdge = GL_CLAMP_TO_EDGE,
        ClampToBorder = GL_CLAMP_TO_BORDER,
        MirroredRepeat = GL_MIRRORED_REPEAT
    }

    void setWrapS(TexWrapType type) {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, type);
        unBind();
    }

    void setWrapT(TexWrapType type) {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, type);
        unBind();
    }

    void bind() {
        glBindTexture(GL_TEXTURE_2D, texID);
    }

    void unBind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void write(void delegate() func) {
        if (writeFbo is null) writeFbo = new FrameBufferObject;
        //writeFbo.attachTextureAsColor(this);
        writeFbo.write(width, height, func);
    }

    void writeBegin() {
        if (writeFbo is null) writeFbo = new FrameBufferObject;
        //writeFbo.attachTextureAsDepth(this);
        writeFbo.writeBegin(width, height);
    }

    void writeEnd(){
        writeFbo.writeEnd();
    }

    alias texID this;
}
