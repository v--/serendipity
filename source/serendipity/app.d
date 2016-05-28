module serendipity.app;

import core.memory : GC;
import std.typecons : scoped;
import std.conv : to;
import subscribed;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.factory;
import serendipity.support.alsa;
import serendipity.reader.result;

enum chunkSize = 16_000;

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
    auto writer = ALSADevice("pulse", true, 32, 16_000);

    while (reader.readable)
    {
        writer.play(reader.read(chunkSize));
    }
}
