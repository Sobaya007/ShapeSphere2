module sbylib.geometry.Face;

import std.conv, std.algorithm, std.math, std.array;

import sbylib.geometry;
import sbylib.math;

class Face() {
    immutable {
        uint[] indexList;
    }

    this (uint[] indexList) {
        assert(indexList.length == 2 || indexList.length == 3);
        this.indexList = indexList;
    }
}
