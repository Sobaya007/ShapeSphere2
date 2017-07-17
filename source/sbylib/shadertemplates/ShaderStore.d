module sbylib.shadertemplates.ShaderStore;

import sbylib;

//class ShaderStore {
//    private static ShaderProgram[string] shaderList;
//
//    static void init() {
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
