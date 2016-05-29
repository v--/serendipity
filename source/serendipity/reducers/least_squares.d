module serendipity.reducers.least_squares;

import serendipity.support.matrix;

auto leastSquares(T, size_t cols, size_t rows)(inout Matrix!(T, cols, rows) matrix, inout ColVector!(T, cols) trainingSet)
{
    immutable transposed = transpose(matrix);
    return inverse(transposed * matrix) * transposed * trainingSet;
}

unittest
{
    immutable data = ColVector!(double, 2)([1.0, 2.0]);
    immutable results = ColVector!(double, 2)([2.0, 4.0]);
    assert(leastSquares!(double, 2, 1)(data, results) == [2.0]);
}

unittest
{
    immutable data = Matrix!(double, 2, 2)([
        1.0, 1.0,
        1.0, 2.0
    ]);

    immutable results = ColVector!(double, 2)([1.0, 2.0]);
    immutable regression = leastSquares!(double, 2, 2)(data, results);
    immutable translation = regression[0, 0];
    immutable scale = regression[1, 0];
    assert(translation == 0);
    assert(scale == 1);
}

unittest
{
    immutable data = Matrix!(double, 3, 3)([
        1.0, 1.0, 1.0,
        1.0, 2.0, 3.0,
        1.0, 4.0, 9.0
    ]);

    immutable results = ColVector!(double, 3)([1.0, 4.0, 9.0]);
    immutable regression = leastSquares!(double, 3, 3)(data, results);
    assert(regression == [-2.5, 4, -0.5]);
}
