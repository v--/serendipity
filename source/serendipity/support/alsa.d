module serendipity.support.alsa;

import core.memory : GC;
import std.typecons : Unqual, scoped;
import std.range : isInputRange;
import std.conv : to;
import deimos.alsa.pcm;

import serendipity.reader.iface;
import serendipity.reader.result;

private
{
    /// Missing binding from the deimos port
    extern (C) char* snd_strerror(int code);

    int enforceALSA(int value, lazy string message)
    {
        import std.string : format, fromStringz;
        assert(value >= 0, "ALSA PCM Error: %s. %s.".format(message(), fromStringz(snd_strerror(value))));
        return value;
    }
}

struct ALSADevice
{
    snd_pcm_t* handle;
    ubyte _depth;
    uint _rate;

    @property @safe @nogc const
    {
        ubyte depth()
        {
            return _depth;
        }

        uint rate()
        {
            return _rate;
        }
    }

    this(string name, ubyte depth, uint rate)
    {
        snd_pcm_hw_params_t* hwparams;
        _depth = depth;
        _rate = rate;
        auto format = snd_pcm_build_linear_format(depth, depth, false, false);

        enforceALSA(
            snd_pcm_open(&handle, "default", snd_pcm_stream_t.PLAYBACK, 0),
            "Could not open '" ~ name ~ "'"
        );

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
            snd_pcm_hw_params_set_rate_near(handle, hwparams, &rate, null),
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

        enforceALSA(
            snd_pcm_prepare(handle),
            "Could not prepare '" ~ name ~"' for use"
        );
    }

    ~this()
    {
        snd_pcm_drain(handle);
    }

    IReaderResult read(size_t amount)
    {
        auto result = constructResult(depth);
        result.allocate(amount);

        result.size = enforceALSA(
            cast(int)snd_pcm_readi(handle, result.dataPtr, amount),
            "Error reading the stream"
        );

        return result;
    }

    void play(R)(R stream) if (isInputRange!(Unqual!R))
    {
        import std.array : array;
        auto data = stream.array;

        enforceALSA(
            cast(int)snd_pcm_writei(handle, data.ptr, data.length),
            "Could not play the stream"
        );

        enforceALSA(
            snd_pcm_wait(handle, -1),
            "Could not wait for the sound range to end"
        );

        enforceALSA(
            snd_pcm_drain(handle),
            "Could not wait for the handle to drain"
        );
    }
}
