module serendipity.fluidsynth;

struct fluid_settings_t;
extern (C) fluid_settings_t* new_fluid_settings();

/// Example:
///  fluid_settings_t* settings;
///  settings = new_fluid_settings();
