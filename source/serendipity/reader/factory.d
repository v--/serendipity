module serendipity.reader.factory;

import std.experimental.allocator;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.wav;
import serendipity.reader.alsa;

IReader constructReader(SerendipitySettings* settings, SerendipityLogger logger)
{
    switch (settings.reader)
    {
        case "alsa": return theAllocator.make!ALSAReader(settings, logger);
        case "wav": return theAllocator.make!WAVReader(settings, logger);
        default:
            assert(false, "Invalid reader '" ~ settings.reader ~ "'.");
    }
}
