module serendipity.reader.result;

import std.conv : to;
import std.experimental.allocator;

struct ReaderResult
{
    private
    {
        size_t pos;
        ubyte depth;
        size_t capacity;
    }

    int[] payload;
    size_t length;

    this(ubyte depth, size_t capacity)
    in
    {
        assert(depth % 8 == 0, "The depth must be a multiple of 8.");
        assert(depth <= 32, "The depth cannot be greater than 32.");
    }
    body
    {
        payload = theAllocator.makeArray!int(capacity);
        this.capacity = capacity;
        depth = depth;
    }

    ~this()
    {
        theAllocator.dispose(payload);
    }

    bool empty() @property @safe const
    {
        return pos == length;
    }

    int front() @property @safe const
    {
        assert(this.length != 0, "The range is empty.");
        return payload[pos];
    }

    void popFront() @safe @nogc
    {
        assert(pos < length, "Cannot pop an empty range.");
        pos++;
    }

    ReaderResult save() @safe @nogc
    {
        return this;
    }
}
