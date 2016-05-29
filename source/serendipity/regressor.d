module serendipity.regressor;

import serendipity.settings;
import serendipity.constants;
import serendipity.reducers.least_squares;

struct Regressor
{
    struct Result
    {
        double tempo;
        double scale;
    }

    @disable this();
    this(string file)
    {

    }

    Result predict(double[lpccCount] input)
    {
        return Result(0, 0);
    }
}
