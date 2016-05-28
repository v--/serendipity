module serendipity.reader.iface;

import serendipity.reader.result;

interface IReader
{
    @property @safe @nogc const
    {
        bool readable();
        ubyte depth();
        uint rate();
    }

    ReaderResult read(size_t amount);
}
