module serendipity.reader.wav;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.result;
import serendipity.support.wav;

class WAVReader: IReader
{
    WAVFile!(byte[]) file;
    size_t pos;

    this(SerendipitySettings* settings, SerendipityLogger logger)
    {
        import std.file : read;
        auto raw = cast(byte[])read(settings.source);
        file = WAVFile!(byte[])(raw);
        logger.infof("Read a WAV file with bit depth %d and sample rate %d.", file.bitDepth, file.sampleRate);
    }

    override
    {
        @property @safe @nogc const
        {
            bool readable()
            {
                return pos < file.size;
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

        IReaderResult read(size_t amount)
        {
            import std.algorithm : min;
            auto result = constructResult(depth);
            result.capacity = amount;
            result.size = min(amount, file.size - pos);
            result.setDataPtr(cast(void*)file.data[pos..pos + amount].ptr, depth);
            return result;
        }
    }
}
