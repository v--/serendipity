module serendipity.support.wav;

import std.traits : Unqual;
import std.conv : to;
import std.range;

struct WAVFile(R) if (isInputRange!(Unqual!R) && is(ElementType!R == ubyte))
{
    //const
    //{
        ubyte bitDepth;
        uint sampleRate;
        size_t size;
        R data;
    //}

    this(R data)
    {
        auto header = data.takeExactly(44).chunks(4);

        immutable chunkFormat = cast(string)header.front;
        assert(chunkFormat == "RIFF", "RIFF magic number is missing.");
        header.popFront();

        immutable chunkSize = *cast(uint*)header.front;
        assert(chunkSize > 36, "Invalid chunk size.");
        header.popFront();

        immutable format = cast(string)header.front;
        assert(format == "WAVE", "This file is not in WAV format.");
        header.popFront();

        immutable fmtId = cast(string)header.front;
        assert(fmtId == "fmt ", "Invalid fmt subchunk id.");
        header.popFront();

        immutable fmtSize = *cast(uint*)header.front;
        assert(fmtSize == 16, "Subchunk size indicates this is not a PCM RIFF format.");
        header.popFront();

        immutable audioFormat = *cast(ushort*)chunks(header.front, 2)[0];
        assert(audioFormat == 1, "Compressed audio formats are not supported.");

        immutable numChannels = *cast(ushort*)chunks(header.front, 2)[1];
        assert(numChannels == 1, "Only single channel audio is currently supported.");
        header.popFront();

        immutable sampleRate = *cast(uint*)header.front;
        assert(sampleRate > 0, "Invalid sample rate.");
        header.popFront();

        immutable byteRate = *cast(int*)header.front;
        assert(byteRate % sampleRate * numChannels / 8 == 0, "Invalid byte rate.");
        header.popFront();

        immutable blockAlign = *cast(ushort*)chunks(header.front, 2)[0];
        assert(blockAlign / 8 % numChannels == 0, "Invalid block alignment.");

        immutable bitsPerSample = *cast(ushort*)chunks(header.front, 2)[1];
        assert(bitsPerSample % 8 == 0, "Invalid bit depth.");
        header.popFront();

        immutable dataId = cast(string)header.front;
        assert(dataId == "data", "Invalid data subchunk id.");
        header.popFront();

        immutable dataSize = *cast(uint*)header.front;
        assert(dataSize + fmtSize + 20 == chunkSize, "Subchunk size sum does not match chunk size.");
        header.popFront();

        this.bitDepth = to!ubyte(bitsPerSample);
        this.size = dataSize;
        this.sampleRate = sampleRate;
        this.data = data.drop(44);
    }
}
