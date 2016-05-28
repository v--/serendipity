module serendipity.support.upsample;

version (LittleEndian):

int upsample(const inout(ubyte)[] sample)
{
    ubyte[4] array;
    array[4 - sample.length..4] = sample[];
    return *cast(int*)array;
}

unittest
{
    assert(cast(byte)0b1111_1111 == -1);

    assert(upsample([0]) == 0);
    assert(upsample([0, 0, 0, 0]) == 0);
    assert(upsample([1, 0, 0, 0]) == 1);
    assert(upsample([1, 0, 0]) == 256);
}
