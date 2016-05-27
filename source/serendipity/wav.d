module serendipity.reader.wav;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.result;

class WAVReader: IReader
{
    this(SerendipitySettings* settings, SerendipityLogger logger)
    {

    }

    override bool readable() @property @safe @nogc const
    {
        return true;
    }

    override IReaderResult read(size_t amount) @safe @nogc
    {
        return null;
    }
}
