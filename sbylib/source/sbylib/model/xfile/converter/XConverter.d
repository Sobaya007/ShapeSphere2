module sbylib.model.xfile.converter.XConverter;

// Converter: S -> T

interface XConverter(S, T) {
    T run(S src);
}
