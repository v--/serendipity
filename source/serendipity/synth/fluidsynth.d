module serendipity.synth.fluidsynth;

import serendipity.synth.iface : Scale;
import serendipity.synth.synth;

struct fluid_settings_t;
struct fluid_synth_t;
struct fluid_audio_driver_t;
struct fluid_sequencer_t;
struct fluid_event_t;

@nogc @safe
{
    extern (C) fluid_settings_t* new_fluid_settings();
    extern (C) fluid_synth_t* new_fluid_synth(fluid_settings_t* settings);
    extern (C) fluid_audio_driver_t* new_fluid_audio_driver(fluid_settings_t* settings, fluid_synth_t* synth);
    extern (C) fluid_sequencer_t* new_fluid_sequencer2(int use_system_timer);
    extern (C) short fluid_sequencer_register_fluidsynth(fluid_sequencer_t* seq, fluid_synth_t* synth);
    extern (C) int fluid_synth_sfload(fluid_synth_t* synth, const char* filename, int reset_presets);
    extern (C) uint fluid_sequencer_get_tick(fluid_sequencer_t* seq);
    extern (C) fluid_event_t* new_fluid_event();
    extern (C) void fluid_event_set_source(fluid_event_t* event, short src);
    extern (C) void fluid_event_set_dest(fluid_event_t* event, short dest);
    extern (C) void fluid_event_noteon(fluid_event_t* event, int channel, short key, short velocity);
    extern (C) int fluid_sequencer_send_at(fluid_sequencer_t* seq, fluid_event_t* event, uint time, int absolute);
    extern (C) void delete_fluid_event(fluid_event_t* event);
    extern (C) void delete_fluid_sequencer(fluid_sequencer_t* seq);
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

        override protected void sendNote(int channel, short key, short velocity, uint duration, uint date)
        {
            fluid_event_t* event = new_fluid_event();
            fluid_event_set_source(event, -1);
            fluid_event_set_dest(event, synthSequencerID);
            fluid_event_note(event, channel, key, velocity);
            int fluid_res = fluid_sequencer_send_at(sequencer, event, date, duration);
            delete_fluid_event(event);
        }

        this(string soundfont, uint durationScale = 10, uint offset = 0, uint spacing = 0, uint tempo = 1, uint volume = 1, Scale scale = Scale.NATURAL)
        {
            super(durationScale, offset, spacing, tempo, volume, scale);
            settings = new_fluid_settings();
            synth = new_fluid_synth(settings);
            adriver = new_fluid_audio_driver(settings, synth);
            sequencer = new_fluid_sequencer2(0);

            // register synth as first destination
            synthSequencerID = fluid_sequencer_register_fluidsynth(sequencer, synth);

            // register client as second destination
            clientSequencerID = fluid_sequencer_register_client(sequencer, "me", NULL, NULL);

            fluid_synth_sfload(synth, soundfont, 1);
        }

        ~this()
        {
            delete_fluid_sequencer(sequencer);
            delete_fluid_audio_driver(adriver);
            delete_fluid_synth(synth);
        }
    }

    override void play(double[] freqs, uint channel, bool parallel = false)
    {
        import std.algorithm : map;
        auto keys = freqs.map!(a => 64 * (a + 1));
        uint now = fluid_sequencer_get_tick(sequencer) + offset;
        uint noteDuration = tempo / freqs.length;

        foreach (key; keys)
        {
            sendNote(channel, key + scale, velocity, noteDuration, now);

            if (!parallel)
                now += noteDuration + spacing;
        }
    }
}
