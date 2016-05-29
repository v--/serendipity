module serendipity.synth.fluidsynth;

import serendipity.synth.iface : Scale;
import serendipity.synth.synth;

struct fluid_settings_t;
struct fluid_synth_t;
struct fluid_audio_driver_t;
struct fluid_sequencer_t;
struct fluid_event_t;

alias fluid_event_callback_t = void function(uint time, fluid_event_t* event, fluid_sequencer_t* seq, void* data);

@nogc @safe
{
    extern (C) fluid_settings_t* new_fluid_settings();
    extern (C) fluid_synth_t* new_fluid_synth(fluid_settings_t* settings);
    extern (C) fluid_audio_driver_t* new_fluid_audio_driver(fluid_settings_t* settings, fluid_synth_t* synth);
    extern (C) int fluid_settings_setstr(fluid_settings_t* settings, const char* name, const char* str);
    extern (C) fluid_sequencer_t* new_fluid_sequencer2(int use_system_timer);
    extern (C) short fluid_sequencer_register_fluidsynth(fluid_sequencer_t* sequencer, fluid_synth_t* synth);
    extern (C) short fluid_sequencer_register_client(fluid_sequencer_t* sequencer, const char* name, fluid_event_callback_t callback, void* data);
    extern (C) int fluid_synth_sfload(fluid_synth_t* synth, const char* filename, int reset_presets);
    extern (C) uint fluid_sequencer_get_tick(fluid_sequencer_t* sequencer);
    extern (C) fluid_event_t* new_fluid_event();
    extern (C) void fluid_event_set_source(fluid_event_t* event, short source);
    extern (C) void fluid_event_set_dest(fluid_event_t* event, short destination);
    extern (C) void fluid_event_note(fluid_event_t* event, int channel, short key, short velocity, uint duration);
    extern (C) int fluid_sequencer_send_at(fluid_sequencer_t* sequencer, fluid_event_t* event, uint time, int absolute);
    extern (C) void delete_fluid_event(fluid_event_t* event);
    extern (C) void delete_fluid_sequencer(fluid_sequencer_t* sequencer);
    extern (C) void delete_fluid_audio_driver(fluid_audio_driver_t* driver);
    extern (C) int delete_fluid_synth(fluid_synth_t* synth);
}

class FluidSynth: Synth
{
    @nogc @safe
    {
        private
        {
            fluid_settings_t* settings;
            fluid_synth_t* synth;
            fluid_audio_driver_t* adriver;
            fluid_sequencer_t* sequencer;

            short synthSequencerID, clientSequencerID;
        }

        private void initSynth(const char* soundfont)
        {
            settings = new_fluid_settings();
            fluid_settings_setstr(settings, "audio.driver", "alsa");
            synth = new_fluid_synth(settings);
            adriver = new_fluid_audio_driver(settings, synth);
            sequencer = new_fluid_sequencer2(0);

            // register synth as first destination
            synthSequencerID = fluid_sequencer_register_fluidsynth(sequencer, synth);

            // register client as second destination
            clientSequencerID = fluid_sequencer_register_client(sequencer, "me", null, null);

            fluid_synth_sfload(synth, soundfont, 1);
        }

        private void destroySynth()
        {
            delete_fluid_sequencer(sequencer);
            delete_fluid_audio_driver(adriver);
            delete_fluid_synth(synth);
        }

        @nogc @safe protected void sendNote(int channel, short key, short velocity, uint duration, uint date)
        {
            fluid_event_t* event = new_fluid_event();
            fluid_event_set_source(event, -1);
            fluid_event_set_dest(event, synthSequencerID);
            fluid_event_note(event, channel, key, velocity, duration);
            fluid_sequencer_send_at(sequencer, event, date, 1);
            delete_fluid_event(event);
        }
    }

    this(string soundfont, uint durationScale = 10, uint offset = 0, uint spacing = 0, uint tempo = 1, short volume = 1, Scale scale = Scale.NATURAL)
    {
        import std.string : toStringz;
        super(durationScale, offset, spacing, tempo, volume, scale);
        initSynth(soundfont.toStringz());
    }

    ~this()
    {
        destroySynth();
    }

    void play(double[] freqs, int channel, bool parallel = false)
    {
        import std.algorithm : map;
        auto keys = freqs.map!(a => 64 * (a + 1));
        uint now = fluid_sequencer_get_tick(sequencer) + offset();
        uint noteDuration = cast(uint)(tempo / freqs.length);

        foreach (key; keys)
        {
            sendNote(channel, cast(short)(key + scale()), volume(), noteDuration, now);

            if (!parallel)
                now += noteDuration + spacing();
        }
    }
}
