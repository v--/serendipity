module serendipity.reader.result;

import std.conv : to;
import std.experimental.allocator;

import serendipity.reader.iface;

class ReaderResult(ubyte depth): IReaderResult
{
    static if (depth == 8)
        alias Sample = byte;
    else static if (depth == 16)
        alias Sample = short;
    else static if (depth == 24)
    {
        /// Only works on little endian architectures at the moment
        struct Sample
        {
            private ubyte[3] payload;

            enum max = int.max >> 8;
            enum min = int.min >> 8;

            this(ubyte a, ubyte b, ubyte c)
            {
                payload = [a, b, c];
            }

            int toInt() const
            {
                int result;

                result <<= 8;
                result |= payload[2];
                result &= 0b0111_1111;

                result <<= 8;
                result |= payload[1];

                result <<= 8;
                result |= payload[0];

                if (payload[2] & 0b1000_0000)
                    result *= -1;

                return result;
            }

            alias toInt this;
        }
    }
    else
        static assert(false, "The depth " ~ to!string(depth) ~ " is not currently supported.");

    private
    {
        size_t pos;
        size_t _size;
        size_t capacity;
    }

    package Sample[] payload;

    this(size_t capacity)
    {
        this.capacity = capacity;
        payload = theAllocator.makeArray!Sample(capacity);
    }

    ~this()
    {
        theAllocator.dispose(payload);
    }

    override
    {
        size_t size() @safe @nogc const
        {
            return _size;
        }

        void size(size_t size) @property @safe @nogc
        in
        {
            assert(size < capacity, "The new result size cannot be greater than it's capacity.");
        }
        body
        {
            _size = size;
        }

        void* dataPtr() @property @nogc const
        {
            return cast(void*)payload.ptr;
        }

        bool empty() @property @safe @nogc const
        {
            return pos == _size;
        }

        int front() @property @safe @nogc const
        {
            return payload[pos];
        }

        void popFront() @safe @nogc
        {
            assert(pos < capacity, "Cannot pop an empty range.");
            pos++;
        }

    }
}

IReaderResult constructResult(ubyte depth, size_t capacity)
{
    switch (depth)
    {
    case 8: return theAllocator.make!(ReaderResult!8)(capacity);
    case 16: return theAllocator.make!(ReaderResult!16)(capacity);
    case 24: return theAllocator.make!(ReaderResult!24)(capacity);
    default: assert(false, "The depth " ~ to!string(depth) ~ " is not currently supported.");
    }
}
