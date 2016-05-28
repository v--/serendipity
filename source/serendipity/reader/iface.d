module serendipity.reader.iface;

interface IReaderResult
{
    @property @safe @nogc const
    {
        int front();
        size_t size();
        size_t capacity();
    }
        bool empty();

    void allocate(size_t capacity);
    void popFront() @safe ;
    void size(size_t size) @property @safe @nogc;
    void capacity(size_t capacity) @property @safe @nogc;
    void* dataPtr() @property @nogc const;
    void setDataPtr(void* value, ubyte depth);
}

interface IReader
{
    @property @safe @nogc const
    {
        bool readable();
        ubyte depth();
        uint rate();
    }

    IReaderResult read(size_t amount);
}
