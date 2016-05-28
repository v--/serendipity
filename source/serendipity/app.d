module serendipity.app;

import core.memory : GC;
import std.typecons : scoped;
import std.conv : to;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.factory;
import serendipity.support.alsa;
import subscribed;

enum chunkSize = 3 * 16_000;

int main(string[] args)
{
    auto logger = scoped!SerendipityLogger();
    SerendipitySettings settings;

    try
        settings = SerendipitySettings.fromArgs(args);
    catch (ArgParseError e)
    {
        SerendipitySettings.printHelp();
        return 1;
    }
    catch (ArgParseHelp e)
    {
        SerendipitySettings.printHelp();
        return 0;
    }

    GC.collect();
    startEventLoop(&settings, logger);
    return 0;
}

void startEventLoop(SerendipitySettings* settings, SerendipityLogger logger)
{
    auto reader = constructReader(settings, logger);
    auto writer = ALSADevice("pulse", 32, 16_000);

    //while (reader.readable)
    {
        auto result = reader.read(chunkSize);
        import std.stdio: writeln; writeln(result.empty);
        //writer.play(result);

        //foreach (sample; reader.read(chunkSize))
        //{
        //    writeln(sample);
        //}
    }
}
