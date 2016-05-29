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

    @Option("depth")
    @Help("[ALSA only] The bit depth of each sample. 16 and 24-bit samples are supported. Default is 16.")
    ubyte depth = 16;

    @Option("rate")
    @Help("[ALSA only] The required sampling rate. Default is 44100Hz (CD quality).")
    uint rate = 44_100;

    @Option("reader")
    @Help("Either \"wav\" or \"alsa\". Default is \"alsa\".")
    string reader = "alsa";

    @Argument("source")
    @Help("The source file or ALSA device to read from.")
    string source;

    @Argument("regressor")
    @Help("The regressor file to read from.")
    string regressor;
}
