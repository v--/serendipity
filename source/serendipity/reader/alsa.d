module serendipity.reader.alsa;

import std.experimental.allocator;
import std.conv : to;
import deimos.alsa.pcm;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.iface;
import serendipity.reader.result;

/// Missing binding from the deimos port
extern (C) char* snd_strerror(int code);

class ALSAReader: IReader
{
    private
    {
        snd_pcm_t* handle;
        ubyte depth;

        static int enforceALSA(int value, lazy string message)
        {
            import std.string : format, fromStringz;
            assert(value >= 0, "ALSA PCM Error: %s. %s.".format(message(), fromStringz(snd_strerror(value))));
            return value;
        }
    }

    this(SerendipitySettings* settings, SerendipityLogger logger)
    {
        import std.string : toStringz;
        depth = settings.depth;
        snd_pcm_hw_params_t* hwparams;
        auto format = snd_pcm_build_linear_format(depth, depth, false, false);

        enforceALSA(
            snd_pcm_open(&handle, settings.source.toStringz(), snd_pcm_stream_t.CAPTURE, 0),
            "Could not open '" ~ settings.source ~ "'"
        );

        logger.infof("Opened device '%s'", settings.source);

        enforceALSA(
            snd_pcm_hw_params_malloc(&hwparams),
            "Could not allocate the hw param structure"
        );

        enforceALSA(
            snd_pcm_hw_params_any(handle, hwparams),
            "Could not initialize the hw param structure"
        );

        enforceALSA(
            snd_pcm_hw_params_set_access(handle, hwparams, snd_pcm_access_t.RW_INTERLEAVED),
            "Could not set the access type"
        );

        enforceALSA(
            snd_pcm_hw_params_set_format(handle, hwparams, format),
            "Could not set the sample format"
        );

        enforceALSA(
            snd_pcm_hw_params_set_rate_near(handle, hwparams, &settings.rate, null),
            "Could not set the sample rate"
        );

        enforceALSA(
            snd_pcm_hw_params_set_channels(handle, hwparams, 1),
            "Could not set the channel count"
        );

        enforceALSA(
            snd_pcm_hw_params(handle, hwparams),
            "Could not set the hw params"
        );

        snd_pcm_hw_params_free(hwparams);

        logger.infof("Successfully configured device '%s'", settings.source);

        enforceALSA(
            snd_pcm_prepare(handle),
            "Could not prepare " ~ settings.source ~" for use"
        );

        logger.infof("Successfully prepared device '%s' for use", settings.source);
    }

    ~this()
    {
        snd_pcm_close(handle);
    }

    override
    {
        bool readable() @property @safe @nogc const
        {
            return true;
        }

        IReaderResult read(size_t amount)
        {
            auto result = constructResult(depth, amount);

            result.size = enforceALSA(
                cast(int)snd_pcm_readi(handle, result.dataPtr, amount),
                "Error reading the stream"
            );

            import std.stdio: writeln; writeln(result);
            return result;
        }
    }
}
