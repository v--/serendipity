module serendipity.settings;

import std.stdio;
import darg;
public import darg : ArgParseError, ArgParseHelp;

struct SerendipitySettings
{
    static fromArgs(string[] args)
    {
        return parseArgs!SerendipitySettings(args[1..$]);
    }

    static void printHelp()
    {
        writeln(usageString!SerendipitySettings("serendipity"));
        writeln(helpString!SerendipitySettings);
    }

    @Option("help", "h")
    @Help("Prints this help.")
    OptionFlag help;

    @Option("depth", "d")
    @Help("[ALSA only] The bit depth of each sample. 16 and 24-bit samples are supported. Default is 16.")
    ubyte depth = 16;

    @Option("rate", "r")
    @Help("[ALSA only] The required sampling rate. Default is 44100Hz (CD quality).")
    uint rate = 44_100;

    @Option("reader", "i")
    @Help("Either \"wav\" or \"alsa\". Default is \"alsa\".")
    string reader = "alsa";

    @Option("soundfont", "f")
    @Help("The SoundFont file for FluidSynth.")
    string soundfont;

    @Option("entropy-rate", "e")
    @Help("The quotient which determines the sample size for the pink noise melody template (pink noise sample size = entropy rate * input chunk size). Default is 1.")
    double entropyRate = 1;

    @Option("channel", "c")
    @Help("The MIDI channel on which the melody will be played. Defaults to 0.")
    int channel = 0;

    @Argument("source")
    @Help("The source file or ALSA device to read from.")
    string source;

    @Argument("regressor")
    @Help("The regressor file to read from.")
    string regressor;
}
