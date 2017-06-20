module sbylib.shadertemplates.ShaderStore;

import sbylib;

//class ShaderStore {
//    private static ShaderProgram[string] shaderList;
//
//    static void init() {
////        /*
////         テクスチャ座標から白黒のチェック模様を表示。
////         Built-in: gl_Vertex
////         gl_MultiTexCoord0
////uniform:  mWorld
////mViewProj
////       */
////        shaderList["Check"] = new ShaderProgram(
////                "#version 330
////      in vec4 mVertex;
////      in vec2 mTexcoord;
////      uniform mat4 mWorld;
////      uniform mat4 mViewProj;
////      out vec3 n;
////      out vec2 tc;
////
////      void main() {
////      gl_Position = mViewProj * mWorld * mVertex;
////      tc = mTexcoord;
////      }
////      ",
////                "#version 330
////      in vec2 tc;
////      out vec4 FragColor;
////      void main() {
////      if ( ( mod(tc.x,0.1) - 0.05) * ( mod(tc.y,0.1) - 0.05) < 0) 
////      FragColor = vec4(.7,.7,.7,1);
////      else
////        FragColor = vec4(.2,.2,.2,1);
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////        /*
////         グローバル座標系のx,y,z軸を表示。２次元専用。
////         Built-in: gl_Vertex
////Uniform:  mView
////       */
////        shaderList["Compass"] = new ShaderProgram("#version 330
////      in vec4 mVertex;
////      out vec2 tc;
////
////      void main() {
////      gl_Position = mVertex;
////      tc = mVertex.xy * .5;
////      }
////      ",
////                "#version 330
////      uniform mat4 mView;
////      in vec2 tc;
////      out vec4 FragColor;
////
////      float dist(vec2 v, vec2 p) {
////      float len = length(p);
////      float dot = dot(v, p);
////      return sqrt(len*len - dot*dot);
////      }
////
////      void main() {
////        vec4 xvec = vec4(1,0,0,0);
////        vec4 yvec = vec4(0,1,0,0);
////        vec4 zvec = vec4(0,0,1,0);
////        xvec = mView * xvec;
////        yvec = mView * yvec;
////        zvec = mView * zvec;
////        const float border = 0.01;
////        FragColor = vec4(0,0,0,0);
////        if (length(tc) > 0.4) return;
////        if (dist(normalize(xvec.xy), tc) < border) FragColor += vec4(1, 0, 0, 1) * (dot(xvec.xy, tc) < 0 ? 0.5 : 1);
////        if (dist(normalize(yvec.xy), tc) < border) FragColor += vec4(0, 1, 0, 1) * (dot(yvec.xy, tc) < 0 ? 0.5 : 1);
////        if (dist(normalize(zvec.xy), tc) < border) FragColor += vec4(0, 0, 1, 1) * (dot(zvec.xy, tc) < 0 ? 0.5 : 1);
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////        /*
////         グローバル座標系のx,y,z軸を表示。２次元専用。
////         Built-in: gl_Vertex
////         gl_Normal
////Uniform:  mWorld
////mViewProj
////lightPos
////cameraPos
////       */
////
////        /*		shaderList["Phong"] = new ShaderProgram(
////            "
////            uniform mat4 mWorld;
////            uniform mat4 mViewProj;
////            varying vec4 p;
////            varying vec3 n;
////            varying vec2 tc;
////
////            void main() {
////            gl_Position = mViewProj * mWorld * gl_Vertex;
////            mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
////            n = m2 * gl_Normal;
////            p = mWorld * gl_Vertex;
////            tc = gl_MultiTexCoord0.xy;
////            }",
////            "
////            uniform vec3 lightPos;
////            uniform vec3 cameraPos;
////            uniform sampler2D mTexture;
////            uniform sampler2D mBackBuffer;
////
////            varying vec4 p;
////            varying vec3 n;
////            varying vec2 tc;
////
////            void main() {
////
////            vec3 ambient = vec3(1,1,1) * .1;
////            vec3 diffuse = texture(mTexture, tc).rgb;
////            vec3 specular = vec3(1,1,1);
////            vec3 pos = p.xyz / p.w;
////            gl_FragColor.xyz = 
////            + ambient
////            + diffuse * max(0, dot( normalize(lightPos - pos), n ));
////            + specular * pow(max(0, dot( normalize(cameraPos - pos), normalize(reflect(pos - lightPos.xyz, n)))), 20);
////            gl_FragColor.w = 1;
////            }",
////            ShaderProgram.InputType.SourceCode);
////       */
////        /*
////         指定した色でポリゴンを塗りつぶし
////         Built-in: gl_Vertex
////Uniform:  mWorld
////mViewProj
////color
////       */	
////        shaderList["SimpleColor"] = new ShaderProgram(
////                "#version 330
////      in vec4 mVertex;
////      uniform mat4 mWorld;
////      uniform mat4 mViewProj;
////
////      void main() {
////      gl_Position = mViewProj * mWorld * mVertex;
////      }
////      ",
////                "#version 330
////      uniform vec4 color;
////      out vec4 FragColor;
////      void main() {
////      FragColor = color;
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////
////        /*
////         DrawRect用。矩形を指定した色で塗りつぶす。
////         Built-in: gl_Vertex
////Uniform:  cx       ピクセル単位での矩形の中心座標
////cy
////width    ピクセル単位での矩形の大きさ
////height
////ww       ピクセル単位でのウインドウの大きさ
////wh
////color
////       */
////        shaderList["DrawRect"] = new ShaderProgram("#version 330
////      in vec4 mVertex;
////      uniform float cx, cy, width, height, ww, wh;
////
////      void main() {
////      vec2 v = mVertex.xy;
////      v.x *= width  / ww;
////      v.y *= height / wh;
////      v.x += cx / ww * 2 - 1;
////      v.y += cy / wh * 2 - 1;
////      gl_Position = vec4(v, 0, 1);
////      }
////      ",
////                "#version 330
////      uniform vec4 color;
////      out vec4 FragColor;
////      void main() {
////      FragColor = color;
////      FragColor.a = 1;
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////
////        /*
////         DrawImage用。矩形領域に指定した画像を貼る。	
////         Built-in: gl_Vertex
////Uniform:  cx       ピクセル単位での矩形の中心座標
////cy
////width    ピクセル単位での矩形の大きさ
////height
////ww       ピクセル単位でのウインドウの大きさ
////wh
////mTexture
////       */
////        shaderList["DrawImage"] = new ShaderProgram("#version 330
////      in vec4 mVertex;
////      uniform float cx, cy, width, height, ww, wh;
////      out vec2 tc;
////
////      void main() {
////      vec2 v = mVertex.xy;
////      v.x *= width  / ww;
////      v.y *= height / wh;
////      v.x += cx / ww * 2 - 1;
////      v.y += cy / wh * 2 - 1;
////      gl_Position = vec4(v, 0, 1);
////      tc = mVertex.xy * .5 + .5;
////      }
////      ",
////                "#version 330
////      uniform sampler2D mTexture;
////      in vec2 tc;
////      out vec4 FragColor;
////      void main() {
////      FragColor = texture(mTexture, tc);
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////
////        /*
////         DrawImageWithColor用。矩形領域に指定した画像を貼る。	
////         Built-in: gl_Vertex
////Uniform:  cx       ピクセル単位での矩形の中心座標
////cy
////width    ピクセル単位での矩形の大きさ
////height
////ww       ピクセル単位でのウインドウの大きさ
////wh
////color    描画色
////mTexture
////       */
////        shaderList["DrawImageWithColor"] = new ShaderProgram("#version 330
////      in vec4 mVertex;
////      uniform float cx, cy, width, height, ww, wh;
////      out vec2 tc;
////
////      void main() {
////      vec2 v = mVertex.xy;
////      v.x *= width  / ww;
////      v.y *= height / wh;
////      v.x += cx / ww * 2 - 1;
////      v.y += cy / wh * 2 - 1;
////      gl_Position = vec4(v, 0, 1);
////      tc = mVertex.xy * .5 + .5;
////      }
////      ",
////                "#version 330
////      uniform sampler2D mTexture;
////      uniform vec4 color;
////      in vec2 tc;
////      out vec4 FragColor;
////      void main() {
////        FragColor = texture(mTexture, tc)*color;
////      }
////      ",
////                ShaderProgram.InputType.SourceCode);
////
////        /*
////         DrawCircle用。円の輪郭を指定した色で塗りつぶす。
////         Built-in: gl_Vertex
////Uniform: 
////cx       ピクセル単位での円の中心座標
////cy
////width    ピクセル単位での円の大きさ
////height
////ww       ピクセル単位でのウインドウの大きさ
////wh
////color    描画色
////thickness ピクセル単位での円の太さ
////       */
////        shaderList["DrawCircle"] = new ShaderProgram("#version 330
////      in vec4 mVertex;
////      uniform float cx, cy, width, height, ww, wh;
////      out vec2 tc;
////
////      void main() {
////      vec2 v = mVertex.xy;
////      v.x *= width  / ww;
////      v.y *= height / wh;
////      v.x += cx / ww * 2 - 1;
////      v.y += cy / wh * 2 - 1;
////      gl_Position = vec4(v, 0, 1);
////      tc = mVertex.xy * .5 + .5;
////      }
////      ",
////                "#version 330
////      uniform sampler2D mTexture;
////      uniform float ww, wh;
////      uniform float thickness;
////      uniform float width,height;
////      uniform vec4 color;
////      in vec2 tc;
////      out vec4 FragColor;
////      void main() {
////        vec2 t = tc - vec2(0.5, 0.5);
////        t.x *= width; t.y *= height;
////
////        if (thickness != 0) {
////          if (
////              t.x *t.x / width/width*4 + t.y * t.y / height/height*4 < 1
////              && t.x *t.x / (width/2-thickness) / (width/2-thickness) + t.y * t.y / (height/2-thickness)/(height/2-thickness) > 1) FragColor = color;
////          else discard;
////        } else {
////          if (
////              t.x *t.x / width/width*4 + t.y * t.y / height/height*4 < 1) FragColor = color;
////          else discard;
////        }
////      } 
////      ",
////                ShaderProgram.InputType.SourceCode);
//    }
//
//    static ShaderProgram getShader(string key) {
//        return shaderList[key];
//    }
//
//    static void reload(string key) {
//    }
//}
