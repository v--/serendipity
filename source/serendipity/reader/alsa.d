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
    private
    {
        ALSADevice device;

        static int enforceALSA(int value, lazy string message)
        {
            import std.string : format, fromStringz;
            //assert(value >= 0, "ALSA PCM Error: %s. %s.".format(message(), fromStringz(snd_strerror(value))));
            return value;
        }
    }

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
