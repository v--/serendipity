module serendipity.support.matrix;

import std.array;

///
struct Matrix(T, size_t rows, size_t cols) if (rows > 0 && cols > 0)
{
    import std.traits : Unqual, isImplicitlyConvertible;
    import std.range : ElementType, isInputRange;

    ///
    enum rowCount = rows;

    ///
    enum colCount = cols;

    ///
    enum elementCount = cols * rows;

    ///
    enum isSquare = cols == rows;

    T[elementCount] payload;

    /// Assigns an input range's values to the matrix
    this(R)(R range) if (isInputRange!(Unqual!R) && isImplicitlyConvertible!(ElementType!R, T))
    {
        foreach (ref item; payload)
        {
            item = range.front;
            assert(!range.empty, "Not enough elements in the range.");
            range.popFront();
        }
    }

    bool opEquals(R)(R range) const @safe @nogc if (isInputRange!(Unqual!R) && is(ElementType!R == T))
    {
        size_t i;

        foreach (item; range)
            if (payload[i++] != item)
                return false;

        return true;
    }

    size_t toHash() const @safe
    {
        return typeid(T[elementCount]).getHash(payload.ptr);
    }

    ///
    T opIndex(size_t i, size_t j) const @safe @nogc
    in
    {
        assert(i >= 0);
        assert(i < rows);
        assert(j >= 0);
        assert(j < cols);
    }
    body
    {
        return payload[i * cols + j];
    }

    ///
    void opIndexAssign(T value, size_t i, size_t j) @safe @nogc
    in
    {
        assert(i >= 0);
        assert(i < rows);
        assert(j >= 0);
        assert(j < cols);
    }
    body
    {
        payload[i * cols + j] = value;
    }

    auto opUnary(string op: "-")() @safe @nogc const
    {
        return -1 * this;
    }

    ///
    auto opBinary(string op: "+")(inout Matrix!(T, rows, cols) rhl) @safe const
    {
        Matrix!(T, rows, cols) result;

        foreach (i, ref item; result.payload)
            item = payload[i] + rhl.payload[i];

        return result;
    }

    /// Adds square matrices
    unittest
    {
        import std.range : iota;
        immutable a = Matrix!(int, 2, 2)(iota(1, 5));
        immutable b = Matrix!(int, 2, 2)(iota(1, 5));
        immutable c = a + b;
        assert(c == [2, 4, 6, 8]);
    }

    ///
    auto opBinaryRight(string op: "*")(inout T scalar) @safe @nogc const
    {
        Matrix!(T, rows, cols) result;

        foreach (i, item; payload)
            result.payload[i] = scalar * item;

        return result;
    }

    /// Multiplies matrices with scalars
    unittest
    {
        immutable a = Matrix!(int, 2, 2)([1, 2, 3, 4]);
        assert(2 * a == [2, 4, 6, 8]);
    }

    ///
    auto opBinary(string op: "*", size_t n)(inout Matrix!(T, cols, n) rhl) @safe const
    {
        Matrix!(T, rows, n) result;

        foreach (i; 0..rows)
            foreach (j; 0..n)
            {
                T stuff = 0;

                foreach (k; 0..cols)
                    stuff += this[i, k] * rhl[k, j];

                result[i, j] = stuff;
            }

        return result;
    }

    /// Multiplies square matrices
    unittest
    {
        immutable a = Matrix!(int, 2, 2)([1, 2, 3, 4]);
        immutable b = Matrix!(int, 2, 2)([2, 0, 1, 2]);
        immutable c = a * b;
        assert(c == [4, 4, 10, 8]);
    }

    /// Multiplies non-square matrices
    unittest
    {
        import std.range : iota;
        immutable a = Matrix!(int, 2, 3)(iota(1, 7));
        immutable b = Matrix!(int, 3, 2)(iota(7, 13));
        immutable c = a * b;
        static assert(c.colCount == 2 && c.rowCount == 2);
        assert(c == [58, 64, 139, 154]);
    }

    //
    string toString() const
    {
        import std.algorithm : map;
        import std.conv : to;
        import std.string : join;
        string[] result;

        foreach (i; 0..rows)
            result ~= '|' ~ payload[cols * i..cols * (i + 1)].map!(x => to!string(x)).join(", ") ~ '|';

        return result.join("\n");
    }
}

///
auto minorMatrix(T, size_t rows, size_t cols)(inout Matrix!(T, rows, cols) matrix, size_t row, size_t col)
{
    Matrix!(T, rows - 1, cols - 1) result;

    for (size_t i; i < rows; i++)
        for (size_t j; j < cols; j++)
        {
            if (i == row || j == col)
                continue;

            result[i > row ? i - 1 : i, j > col ? j - 1 : j] = matrix[i, j];
        }

    return result;
}

unittest
{
    import std.range : iota;
    auto matrix = Matrix!(int, 3, 3)(iota(0, 9));
    assert(minorMatrix(matrix, 0, 0) == [4, 5, 7, 8]);
    assert(minorMatrix(matrix, 1, 1) == [0, 2, 6, 8]);
}

///
auto transpose(T, size_t rows, size_t cols)(inout Matrix!(T, rows, cols) matrix)
{
    Matrix!(T, cols, rows) result;

    foreach (i; 0..rows)
        foreach (j; 0..cols)
            result.payload[j * rows + i] = matrix[i, j];

    return result;
}

unittest
{
    import std.range : iota;
    auto matrix = Matrix!(int, 3, 3)(iota(0, 9));
    assert(transpose(matrix) == [0, 3, 6, 1, 4, 7, 2, 5, 8]);
}

unittest
{
    import std.range : iota;
    auto matrix = Matrix!(int, 2, 3)(iota(0, 6));
    assert(transpose(matrix) == [0, 3, 1, 4, 2, 5]);
}

///
auto determinant(T, size_t size)(inout Matrix!(T, size, size) matrix)
{
    T result = 0;

    foreach (i; 0..size)
        result += (i % 2 == 0 ? 1 : -1) * matrix[i, 0] * determinant(minorMatrix(matrix, i, 0));

    return result;
}

///
auto determinant(T, size_t size: 1)(inout Matrix!(T, size, size) matrix)
{
    return matrix.payload[0];
}

unittest
{
    assert(determinant(Matrix!(int, 1, 1)([0])) == 0);
    assert(determinant(Matrix!(int, 2, 2)([
        1, 1,
        1, 1
    ])) == 0);

    assert(determinant(Matrix!(int, 2, 2)([
        2, 1,
        1, 1
    ])) == 1);

    assert(determinant(Matrix!(int, 2, 2)([
        1, 1,
        2, 1
    ])) == -1);

    assert(determinant(Matrix!(int, 3, 3)([
        1, 1, 1,
        1, 1, 1,
        1, 1, 1
    ])) == 0);

    assert(determinant(Matrix!(int, 3, 3)([
        -2,  2, -3,
        -1,  1,  3,
         2,  0, -1
    ])) == 18);
}

///
auto inverse(T, size_t size)(inout Matrix!(T, size, size) matrix)
{
    immutable det = determinant(matrix);
    assert(det != 0, "Cannot invert a singular matrix.");
    Matrix!(T, size, size) result;

    foreach (i; 0..size)
        foreach (j; 0..size)
        {
            immutable sign = (i + j) % 2 == 0 ? 1 : -1;
            result[j, i] = sign * determinant(minorMatrix(matrix, i, j)) / det;
        }

    return result;
}

///
auto inverse(T, size_t size: 1)(inout Matrix!(T, size, size) matrix)
{
    immutable det = determinant(matrix);
    assert(det != 0, "Cannot invert a singular matrix.");
    return Matrix!(T, size, size)([1 / matrix[0, 0]]);
}

unittest
{
    assert(inverse(Matrix!(double, 1, 1)([4.0])) == [0.25]);
}

unittest
{
    assert(inverse(Matrix!(int, 2, 2)([
        2, 1,
        1, 1
    ])) == [
        1, -1,
        -1, 2
    ]);
}

unittest
{
    import std.math : feqrel;

    immutable inv = inverse(Matrix!(double, 3, 3)([
         2.0,  1.0,  1.0,
         1.0,  1.0,  1.0,
         2.0,  5.0,  2.0
    ]));

    immutable cmp = [
         1.00000, -1.00000,  0.00000,
         0.00000, -0.666667,  0.333333,
        -1.00000,  2.666667, -0.333333
    ];

    foreach (i, item; inv.payload)
        assert(feqrel(item, cmp[i]) > 5);
}

///
template RowVector(T, size_t size)
{
    alias RowVector = Matrix!(T, 1, size);
}

///
template ColVector(T, size_t size)
{
    alias ColVector = Matrix!(T, size, 1);
}

unittest
{
    import std.range : iota;
    auto numbers = iota(0, 9);
    auto matrix = Matrix!(int, 3, 3)(numbers);

    assert(matrix == numbers);
    assert(matrix[0, 0] == numbers[0]);
    assert(matrix[0, 1] == numbers[1]);
    assert(matrix[1, 0] == numbers[3]);
    assert(matrix[2, 2] == numbers[8]);
}

/// Multiplies column and row vectors
unittest
{
    import std.range : iota;
    immutable a = RowVector!(int, 4)(iota(1, 5));
    immutable b = ColVector!(int, 4)(iota(1, 5));
    immutable c = a * b;
    static assert(c.colCount == 1 && c.rowCount == 1);
    assert(c == [30]);
}
