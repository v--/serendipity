module serendipity.app;

import std.typecons : scoped;
import std.conv : to;

import serendipity.logger;
import serendipity.alsa;
import serendipity.settings;
import subscribed;

void main(string[] args)
{
    auto settings = SerendipitySettings.fromArgs(args);
    auto logger = scoped!SerendipityLogger();

    switch (settings.depth)
    {
    case 16: startLoop!16(settings, logger); break;
    case 24: startLoop!24(settings, logger); break;
    default: assert(false, "The depth " ~ to!string(settings.depth) ~ " is not currently supported.");
    }
}

void startLoop(uint depth)(SerendipitySettings settings, SerendipityLogger logger)
{
    auto reader = ALSAReader!depth(settings.device, settings.rate);
    logger.info("Initialized everything.");

    foreach (sample; reader.read())
    {
        import std.stdio: write; write(sample + 0);
    }
}
