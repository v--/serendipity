module serendipity.reader.result;

import std.conv : to;
import std.experimental.allocator;

import serendipity.reader.iface;

class ReaderResult(ubyte depth): IReaderResult
{
    /// Only works on little endian architectures at the moment
    static if (depth == 16)
        struct Sample
        {
            private short payload;

            this(ubyte a, ubyte b)
            {
                int result;

                result <<= 16;
                result |= payload;
                result &= 0b0111_1111_1111_1111;

                if (payload & 0b1000_0000_0000_0000)
                    result *= -1;
            }

            int toInt() const
            {
                return cast(int)(payload);
            }

            alias toInt this;
        }
    else static if (depth == 24)
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

                return result * byte.max;
            }

            alias toInt this;
        }
        else
            static assert(false, "The depth " ~ to!string(depth) ~ " is not currently supported.");

    private
    {
        size_t pos;
        size_t _size;
        size_t _capacity;
        Sample[] payload;
    }

    void allocate(size_t capacity)
    {
        assert(this.capacity == 0, "The range is already allocated.");
        payload = theAllocator.makeArray!Sample(capacity);
        _capacity = capacity;
    }

    ~this()
    {
        theAllocator.dispose(payload);
    }

    override
    {
        void size(size_t size) @property @safe @nogc
        in
        {
            assert(size < capacity, "The new result size cannot be greater than it's capacity.");
        }
        body
        {
            _size = size;
        }

        size_t size() @safe @nogc const
        {
            return _size;
        }

        void capacity(size_t capacity) @property @safe @nogc
        {
            _capacity = capacity;
        }

        size_t capacity() const @property @safe @nogc
        {
            return _capacity;
        }

        void* dataPtr() @property @nogc const
        {
            return cast(void*)payload.ptr;
        }

        void setDataPtr(void* ptr, ubyte depth)
        {
            payload = cast(Sample[])ptr[0.._size * depth];
        }

        bool empty() @property @safe const
        {
            return pos == _size;
        }

        int front() @property @safe const
        {
            assert(this.capacity != 0, "The range is empty.");
            return payload[pos];
        }

        void popFront() @safe @nogc
        {
            assert(pos < capacity, "Cannot pop an empty range.");
            pos++;
        }
    }
}

IReaderResult constructResult(ubyte depth)
{
    switch (depth)
    {
    case 16: return theAllocator.make!(ReaderResult!16);
    case 24: return theAllocator.make!(ReaderResult!24);
    default: assert(false, "The depth " ~ to!string(depth) ~ " is not currently supported.");
    }
}
