module serendipity.app;

import std.typecons : scoped;

import serendipity.logger;
import serendipity.alsa;
import serendipity.settings;
import subscribed;

void main(string[] args)
{
    auto settings = SerendipitySettings.fromArgs(args);
    auto logger = scoped!SerendipityLogger();
    auto reader = ALSAReader(settings.device, settings.rate);

    logger.info("Initialized everything.");
    reader.read();
}
