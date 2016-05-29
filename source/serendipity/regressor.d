module serendipity.regressor;

import std.algorithm;
import std.regex;
import std.range;
import std.conv;
import std.file;

import serendipity.settings;
import serendipity.constants;
import serendipity.support.matrix;
import serendipity.reducers.least_squares;
import serendipity.reducers.lpcc;
import serendipity.support.wav;
import serendipity.support.upsample;
import serendipity.reader.result;

private enum regex = ctRegex!(`[,\s]+`);

enum BerlinEmotion: Regressor.Result
{
    anger = Regressor.Result(1, 0),
    boredom = Regressor.Result(0.25, 0.5),
    disgust = Regressor.Result(0.5, 0),
    fear = Regressor.Result(0, 0),
    happiness = Regressor.Result(1, 1),
    sadness = Regressor.Result(0, 0),
    neutral = Regressor.Result(0.5, 0.5)
}

private Regressor.Result parseBerlinFileName(string name)
{
    // immutable speakerID = name[0..2];
    // string textID = name[2..5];
    immutable emotionID = name[5];

    switch (emotionID)
    {
        case 'W': return BerlinEmotion.anger;
        case 'L': return BerlinEmotion.boredom;
        case 'E': return BerlinEmotion.disgust;
        case 'A': return BerlinEmotion.fear;
        case 'F': return BerlinEmotion.happiness;
        case 'T': return BerlinEmotion.sadness;
        default: return BerlinEmotion.neutral;
    }
}

struct Regressor
{
    private Matrix!(double, lpccCount, 1) tempoMatrix;
    private Matrix!(double, lpccCount, 1) scaleMatrix;

    struct Result
    {
        double tempo;
        double scale;

        this(double tempo, double scale)
        {
            this.tempo = clamp(tempo, 0, 1);
            this.scale = clamp(scale, 0, 1);
        }
    }

    @disable this();
    // Forgive me for this function
    this(string file)
    {
        if (exists(file))
        {
            auto values = file.readText().splitter(regex).filter!(x => x.length > 0).map!(x => to!double(x)).chunks(lpccCount);
            tempoMatrix = typeof(tempoMatrix)(values.front);
            values.popFront();
            scaleMatrix = typeof(scaleMatrix)(values.front);
        }
        else
        {
            auto trainingSet = Matrix!(double, 536, lpccCount)(repeat(0));
            auto resultSetTempo = ColVector!(double, 536)(repeat(0));
            auto resultSetScale = ColVector!(double, 536)(repeat(0));
            size_t i;

            foreach (entry; dirEntries("./local/wav", SpanMode.shallow))
            {
                import std.path : baseName;

                WAVFile!(ubyte[]) wavFile;

                try
                    wavFile = WAVFile!(ubyte[])(cast(ubyte[])read(entry.name));
                catch (Error)
                {
                    wavFile.sampleRate = chunkSize;
                    wavFile.bitDepth = 32;
                    wavFile.size = chunkSize / 4;
                    wavFile.data = repeat(cast(ubyte)0, chunkSize).array();
                }

                auto readerResult = ReaderResult(wavFile.bitDepth, wavFile.size);
                size_t j;

                foreach (sample; wavFile.data.chunks(wavFile.bitDepth / 8))
                    readerResult.payload[j++] = upsample(sample);

                readerResult.length = wavFile.size / (wavFile.bitDepth / 8);

                foreach (k, item; lpccReducer(readerResult))
                    trainingSet[i, k] = item;

                auto expectedEmotion = parseBerlinFileName(entry.name.baseName());
                resultSetTempo[i, 0] = expectedEmotion.tempo * ushort.max * 10;
                resultSetScale[i, 0] = expectedEmotion.scale * ushort.max * 10;
                i++;
            }

            tempoMatrix = leastSquares!(double, 536, lpccCount)(trainingSet, resultSetTempo);
            scaleMatrix = leastSquares!(double, 536, lpccCount)(trainingSet, resultSetScale);

            write(file, tempoMatrix.payload[].map!(x => to!string(x)).join(',') ~ '\n' ~ scaleMatrix.payload[].map!(x => to!string(x)).join(','));
        }
    }

    Result predict(double[lpccCount] input)
    {
        immutable inputVector = RowVector!(double, lpccCount)(input[]);
        immutable tempo = inputVector * tempoMatrix;
        immutable scale = inputVector * scaleMatrix;

        return Result(0.5 + tempo[0, 0], 0.5 + scale[0, 0]);
    }
}
