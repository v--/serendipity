module serendipity.reducers.lpcc;

import std.algorithm;
import std.range;

import serendipity.constants;
import serendipity.reader.result;
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
    immutable compressed = compressReaderResult(data);
    //foreach (item; compressed)
    return result;
}
