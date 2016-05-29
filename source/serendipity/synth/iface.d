module serendipity.synth.iface;

enum Scale
{
    NATURAL = 0,
    SHARP = 1,
    FLAT = -1
}

class ISynth
{
    protected void sendNote(int channel, short key, short velocity, uint duration, uint date);

    @property
    {
        Scale scale();
        Scale scale(Scale value);
        Scale scale(double arousal);
    }

    @property
    {
        uint tempo();
        uint tempo(uint value);
        uint tempo(double valence);
    }

    @property
    {
        uint volume();
        uint volume(uint value);
        uint volume(double arousal);
    }

    void play(double[] freqs, uint channel, bool parallel = false);
}
