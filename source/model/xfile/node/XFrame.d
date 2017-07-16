module model.xfile.node.XFrame;

import sbylib.math.Matrix;

import model.xfile.node;

struct XFrame {
    string name;
    XFrameTransformMatrix frameTransformMatrix;

    XFrame[] frames; // childrenaddfile
    XMesh[] meshes;
}
