module serendipity.reader.iface;

interface IReaderResult
{
    size_t size() @property @safe @nogc const;
    void size(size_t size) @property @safe @nogc;
    void* dataPtr() @property @nogc const;
    bool empty() @property @safe @nogc const;
    int front() @property @safe @nogc const;
    void popFront() @safe @nogc;
}

interface IReader
{
    bool readable() @property @safe @nogc const;
    IReaderResult read(size_t amount);
}
