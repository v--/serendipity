module serendipity.alsa;

import std.experimental.allocator;
import deimos.alsa.pcm;

/// Missing binding from the deimos port
extern (C) char* snd_strerror(int code);

struct ALSAReader(byte depth)
{
    static if (depth == 16)
        alias Sample = short;
    else static if (depth == 24)
    {
        /// Only little endian
        struct Sample
        {
            private ubyte[3] payload;

            enum max = int.max >> 8;
            enum min = int.min >> 8;

            this(ubyte a, ubyte b, ubyte c)
            {
                payload = [a, b, c];
            }

            int toInt()
            {
                int result;

                result <<= 8;
                result |= payload[2];
                result &= 0b0111_1111;

                result <<= 8;
                result |= payload[1];

                result <<= 8;
                result |= payload[0];

                if (payload[2] & 0b1000_0000)
                    result *= -1;

                return result;
            }

            alias toInt this;
        }

        unittest
        {
            assert(Sample(0, 0, 0) == 0);
            assert(Sample(0, 0, 0b1000_0000).toInt == 0);
            assert(Sample(0xFF, 0, 0).toInt == 255);
            assert(Sample(0, 0xFF, 0).toInt == 255 << 8);
            assert(Sample(0, 0, 0xFF).toInt == -0b0111_1111 << 16);
        }
    }
    else
    {
        static assert(false, "The depth " ~ depth ~ " is not currently supported.");
    }

    @disable this();

    private
    {
        snd_pcm_t* handle;

        enum sampleSize = 24;
        static assert (sampleSize % 8 == 0, "The sample size is not a multiple of 8.");
        enum sampleBytes = sampleSize / 8;
        enum maxBufferSize = 96;
        enum maxReadCount = maxBufferSize / sampleBytes;
        enum pcmFmt = mixin("snd_pcm_format_t.S" ~ sampleSize.stringof ~ "_LE");

        static int enforceALSA(int value, lazy string message)
        {
            import std.string : format, fromStringz;
            assert(value >= 0, "ALSA PCM Error: %s. %s.".format(message(), fromStringz(snd_strerror(value))));
            return value;
        }
    }

    this(string device, uint rate)
    {
        import std.string : toStringz;
        snd_pcm_hw_params_t* hwparams;

        enforceALSA(
            snd_pcm_open(&handle, device.toStringz(), snd_pcm_stream_t.CAPTURE, 0),
            "Could not open '" ~ device
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
            snd_pcm_hw_params_set_format(handle, hwparams, pcmFmt),
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
            "Could not prepare " ~ device ~" for use"
        );
    }

    auto read()
    {
        struct Result
        {
            private
            {
                size_t pos;
                size_t read;
                Sample[maxReadCount] buffer;
            }

            bool empty() const @safe @nogc
            {
                return pos == read;
            }

            Sample front() @safe @nogc
            {
                return buffer[pos];
            }

            void popFront()
            {
                pos++;
            }
        }

        Result result;

        result.read = enforceALSA(
            cast(int)snd_pcm_readi(handle, cast(void*)result.buffer.ptr, maxReadCount - 8),
            "Error reading the stream"
        );

        return result;
    }

    ~this()
    {
        snd_pcm_close(handle);
    }
}
