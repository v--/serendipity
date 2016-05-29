module serendipity.synth.iface;

enum Scale
{
    NATURAL = 0,
    SHARP = 1,
    FLAT = -1
}

interface ISynth
{
    @nogc @safe protected void sendNote(int channel, short key, short velocity, uint duration, uint date);

    @property
    {
        uint durationScale();
        uint offset();
        uint spacing();

        uint tempo();
        uint tempo(uint value);
        uint tempo(double valence);

        short volume();
        short volume(short value);
        short volume(double arousal);

        Scale scale();
        Scale scale(Scale value);
        Scale scale(double arousal);
    }

    void play(double[] freqs, int channel, bool parallel = false);
}
