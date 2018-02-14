module sbylib.geometry.Face;

class Face {
    immutable(uint[]) indexList;

    this (immutable(uint[]) indexList) {
        assert(indexList.length == 2 || indexList.length == 3);
        this.indexList = indexList;
    }
}
