module model.xfile.converter.XConverter;

// Converter: S -> T

interface XConverter(S, T) {
    void run(S src);
    T get();
    void clear();
    bool empty();
}
