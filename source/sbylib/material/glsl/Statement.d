module sbylib.material.glsl.Statement;


interface Statement {
    string graph(bool[]);
    string getCode();
}
