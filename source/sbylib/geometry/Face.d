module sbylib.geometry.Face;

class Face {
    uint[] indexList;

    this (uint[] indexList) {
        assert(indexList.length == 2 || indexList.length == 3);
        this.indexList = indexList;
    }
}
