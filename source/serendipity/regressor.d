module serendipity.regressor;

import std.algorithm;
import std.regex;
import std.conv;

import serendipity.settings;
import serendipity.constants;
import serendipity.support.matrix;
import serendipity.reducers.least_squares;

private enum regex = ctRegex!(`[,\s]+`);

struct Regressor
{
    private
    {
        string file;
        Matrix!(double, lpccCount, 2) matrix;
    }

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
    this(string file)
    {
        import std.file : readText;
        this.file = file;
        auto values = file.readText().splitter(regex).filter!(x => x.length > 0).map!(x => to!double(x));
        this.matrix = typeof(matrix)(values);
    }

    Result predict(double[lpccCount] input)
    {
        immutable inputVector = RowVector!(double, lpccCount)(input[]);
        immutable outputVector = inputVector * matrix;
        return Result(outputVector[0, 0], outputVector[0, 1]);
    }
}
