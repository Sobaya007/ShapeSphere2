module plot.DataSet;

import std.datetime;
import std.string;
import std.conv;
import std.file;
import std.random;
import std.math;
import plot.Data;
import sbylib;

class DataSet {

    Data[][string] datas;
    Mesh[string] lineMesh;
    Label[string] labels;

    this (string path) {
        foreach (line; readText(path).split("\n")) {
            if (line.length == 0) continue;
            auto data = line.split(" ");
            auto first = data[0], latter = data[1..$].join(" ");
            auto tmp = first.split(":");
            auto date = tmp[0..3].join(":");
            SysTime systime;
            systime.fromISOExtString(date);
            string srcPath = tmp[3..$].join(":");
            string name = latter.split(":")[0];
            long time = latter.split(":")[1][1..$].chomp.to!long;
            auto po = new Data(systime, srcPath, name, time);
            if (name !in this.datas) this.datas[name] = new Data[0];
            this.datas[name] ~= po;
        }
        Font font = FontLoader.load(RESOURCE_ROOT ~ "consola.ttf", 64);

        float baseY = 0.9;
        vec3[] colors = [vec3(1,0,0), vec3(0,1,0),vec3(0,0,1), vec3(1,1,0), vec3(1,0,1), vec3(0,1,1), vec3(1,1,1) ];
        foreach (key, value; datas) {
            auto angle = uniform(0, 2 * PI);
            vec3 color = colors[0];
            colors = colors[1..$] ~ colors[0];
            VertexP[] vertices;
            foreach (i, data; value) {
                auto x = cast(float)i / value.length * 0.9 + 0.05;
                auto y = data.time * 0.01 + .2;
                vertices ~= new VertexP(vec3(cast(float)i / value.length * 0.9 + 0.05, data.time * 0.01 + .2, 0));
            }
            auto geom = new GeometryTemp!([Attribute.Position], Prim.LineStrip)(vertices);
            auto mat = new LambertMaterial();
            mat.ambient = color;
            auto mesh = new Mesh(geom, mat);
            lineMesh[key] = mesh;
            Label label = new Label(font, 0.05, color);
            label.text = key;
            label.obj.pos = vec3(0.9, baseY, 0);
            labels[key] = label;

            baseY -= 0.1;
        }
    }
}
