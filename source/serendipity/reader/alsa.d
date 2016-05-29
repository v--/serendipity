module serendipity.reader.alsa;

import std.experimental.allocator;
import std.conv : to;
import deimos.alsa.pcm;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.result;
import serendipity.support.alsa;

class ALSAReader: IReader
{
    private ALSADevice device;

    this(SerendipitySettings* settings, SerendipityLogger logger)
    {
        device = ALSADevice(settings.source, false, settings.depth, settings.rate);
        logger.infof("Successfully prepared device '%s' for use", device.name);
    }

    override
    {
        @property @safe @nogc const
        {
            bool readable()
            {
                return true;
            }

            ubyte depth()
            {
                return device.depth;
            }

            uint rate()
            {
                return device.rate;
            }
        }

        ReaderResult read(size_t amount)
        {
            return device.read(amount);
        }
    }
}
