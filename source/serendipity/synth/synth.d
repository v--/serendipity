module serendipity.synth.synth;

import serendipity.synth.iface;

abstract class Synth: ISynth
{
    private
    {
        uint m_durationScale, m_offset, m_spacing, m_tempo;
        short m_volume;
        Scale m_scale;
    }

    this(uint durationScale = 10, uint offset = 0, uint spacing = 0, uint tempo = 1, short volume = 1, Scale scale = Scale.NATURAL)
    {
        m_durationScale = durationScale;
        m_offset = offset;
        m_spacing = spacing;
        m_tempo = tempo;
        m_volume = volume;
        m_scale = scale;
    }

    @property
    {
        override uint durationScale()
        {
            return m_durationScale;
        }

        override uint offset()
        {
            return m_offset;
        }

        override uint spacing()
        {
            return m_spacing;
        }

        override uint tempo()
        {
            return m_tempo;
        }

        override uint tempo(uint value)
        {
            return m_tempo = value;
        }

        override uint tempo(double valence)
        {
            return m_tempo = cast(uint)(m_durationScale * (1 - valence));
        }

        override short volume()
        {
            return m_volume;
        }

        override short volume(short value)
        {
            return m_volume = value;
        }

        override short volume(double arousal)
        {
            return m_volume = cast(short)(128 * arousal);
        }

        override Scale scale()
        {
            return m_scale;
        }

        override Scale scale(Scale value)
        {
            return m_scale = value;
        }

        override Scale scale(double arousal)
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
}
