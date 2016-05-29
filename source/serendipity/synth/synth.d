module serendipity.synth.synth;

import serendipity.synth.iface;

abstract class Synth: ISynth
{
    @nogc @safe
    {
        private
        {
            uint m_durationScale, m_offset, m_spacing, m_tempo, m_volume;
            Scale m_scale;
        }

        protected void sendNote(int channel, short key, short velocity, uint duration, uint date);

        this(uint durationScale = 10, uint offset = 0, uint spacing = 0, uint tempo = 1, uint volume = 1, Scale scale = Scale.NATURAL)
        {
            m_durationScale = durationScale;
            m_offset = offset;
            m_spacing = spacing;
            m_tempo = tempo;
            m_volume = volume;
            m_scale = scale;
        }
    }

    @property
    {
        Scale scale()
        {
            return m_scale;
        }

        Scale scale(Scale value)
        {
            return m_scale = value;
        }

        Scale scale(double arousal)
        {
            if (arousal >= 0 && arousal < 1 / 3)
                m_scale = Scale.FLAT;
            else if (arousal > 2 / 3 && arousal <= 1)
                m_scale = Scale.SHARP;
            else
                m_scale = Scale.NATURAL;

            return m_scale;
        }
    }

    @property
    {
        uint tempo()
        {
            return m_tempo;
        }

        uint tempo(uint value)
        {
            return m_tempo = value;
        }

        uint tempo(double valence)
        {
            return m_tempo = m_durationScale * cast(uint)(1 - valence);
        }
    }

    @property
    {
        uint volume()
        {
            return m_volume;
        }

        uint volume(uint value)
        {
            return m_tempo = value;
        }

        uint volume(double arousal)
        {
            return m_tempo = 128 * cast(uint)arousal;
        }
    }

    void play(double[] freqs, uint channel, bool parallel = false);
}
