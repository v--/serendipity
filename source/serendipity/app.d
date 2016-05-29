module serendipity.app;

import core.memory : GC;
import std.typecons : scoped;
import std.conv : to;

import serendipity.constants;
import serendipity.logger;
import serendipity.settings;
import serendipity.regressor;
import serendipity.reader.factory;
import serendipity.support.alsa;
import serendipity.reader.result;
import serendipity.reducers.lpcc;
import serendipity.synth.fluidsynth;
import serendipity.synth.noise : generatePinkNoise;

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

private uint roundDownToNearestPowerOfTwo(uint n)
{
    uint power = 1;
    while (power < n)
        power *= 2;
    return power;
}

void startEventLoop(SerendipitySettings* settings, SerendipityLogger logger)
{
    import std.stdio;
    import std.algorithm : fold, map, sum;
    auto reader = constructReader(settings, logger);
    auto writer = ALSADevice("pulse", true, 32, 16_000);
    auto regressor = Regressor(settings.regressor);
    auto synth = new FluidSynth(settings.soundfont);
    auto noiseChunkSize = cast(uint)(settings.entropyRate * chunkSize);

    while (reader.readable)
    {
        auto result = reader.read(chunkSize);
        immutable averageAmplitude = result.map!(a => a / result.length).sum();
        immutable lpcc = lpccReducer(result.save);
        immutable predicted = regressor.predict(lpcc);
        synth.volume = averageAmplitude;
        synth.tempo = predicted.tempo;
        synth.scale = predicted.scale;
        synth.play(generatePinkNoise(roundDownToNearestPowerOfTwo(noiseChunkSize)), settings.channel);
        import std.stdio: writeln; writeln(predicted);
    }
}
