module serendipity.app;

import core.memory : GC;
import std.typecons : scoped;
import std.conv : to;

import serendipity.logger;
import serendipity.settings;
import serendipity.reader.factory;
import subscribed;

enum chunkSize = 128;

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

    while (reader.readable)
        foreach (sample; reader.read(chunkSize))
        {
            import std.stdio: write; write(sample);
        }
}
