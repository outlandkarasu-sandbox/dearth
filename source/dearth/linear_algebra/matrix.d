/**
Matrix module.
*/
module dearth.linear_algebra.matrix;

import std.traits : isNumeric;

/**
Matrix structure.

Params:
    ROWS = matrix rows.
    COLS = matrix columns.
    E = element type.
*/
struct Matrix(size_t ROWS, size_t COLS, E = float)
{
    static assert(ROWS > 0);
    static assert(COLS > 0);
    static assert(isNumeric!E);

    @property const scope
    {
        size_t rows() { return ROWS; }
        size_t columns() { return COLS; }
    }

    /**
    Get an element.

    Params:
        i = row index.
        j = column index.
    Returns:
        element value.
    */
    ref const(E) opIndex(size_t i, size_t j) const return scope
    in (i < ROWS)
    in (j < COLS)
    {
        return elements_[i][j];
    }

private:
    E[COLS][ROWS] elements_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable m = Matrix!(2, 3)([
        [1, 2, 3],
        [4, 5, 6]
    ]);
    assert(m.rows == 2);
    assert(m.columns == 3);

    assert(m[0, 0].isClose(1));
    assert(m[0, 1].isClose(2));
    assert(m[0, 2].isClose(3));
    assert(m[1, 0].isClose(4));
    assert(m[1, 1].isClose(5));
    assert(m[1, 2].isClose(6));
}

