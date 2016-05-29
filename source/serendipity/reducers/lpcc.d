module serendipity.reducers.lpcc;

import std.algorithm;
import std.range;

import serendipity.constants;
import serendipity.reader.result;
import serendipity.support.matrix;
import serendipity.reducers.least_squares;

private auto compressReaderResult(ReaderResult data)
{
    double[lpccCount] result;
    immutable subchunkSize = data.length / lpccCount;
    auto subchunks = data.chunks(subchunkSize);

    foreach (i, ref item; result)
    {
        item = subchunks.front.map!(sample => cast(double)sample / subchunks.front.length).sum();
        subchunks.popFront();
    }

    return result;
}

auto lpccReducer(ReaderResult data)
{
    double[lpccCount] result;
    auto compressed = compressReaderResult(data);

    foreach (i, value; compressed)
    {
        immutable input = ColVector!(double, lpccCount)(iota(0, lpccCount));
        immutable output = ColVector!(double, lpccCount)(compressed[].take(i).chain(repeat(0)));
        immutable prediction = leastSquares!(double, lpccCount, 1)(input, output)[0, 0];
        result[i] = value - prediction;
    }

    return result;
}
