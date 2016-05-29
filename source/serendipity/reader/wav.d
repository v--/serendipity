module serendipity.reader.wav;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.result;
import serendipity.support.wav;
import serendipity.support.upsample;

class WAVReader: IReader
{
    WAVFile!(ubyte[]) file;
    size_t pos;

    this(SerendipitySettings* settings, SerendipityLogger logger)
    {
        import std.file : read;
        auto raw = cast(ubyte[])read(settings.source);
        file = WAVFile!(ubyte[])(raw);
        logger.infof("Read a WAV file with bit depth %d and sample rate %d.", file.bitDepth, file.sampleRate);
    }

    override
    {
        @property @safe @nogc const
        {
            bool readable()
            {
                return pos * file.bitDepth / 8 < file.size;
            }

            ubyte depth()
            {
                return file.bitDepth;
            }

            uint rate()
            {
                return file.sampleRate;
            }
        }

        ReaderResult read(size_t amount)
        {
            import std.algorithm : min;
            import std.range : drop, take, chunks;
            auto result = ReaderResult(depth, amount);
            size_t i;

            foreach (sample; file.data.chunks(depth / 8).drop(pos).take(amount))
                result.payload[i++] = upsample(sample);

            result.length = i;
            pos += i;
            return result;
        }
    }
}
