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

    /**
    Initialize by row major elements.

    Params:
        elements = matrix row major elements.
    */
    static typeof(this) fromRows(scope const(E)[COLS][ROWS] elements)
    {
        auto m = typeof(this)();
        foreach (j; 0 .. COLS)
        {
            foreach (i; 0 .. ROWS)
            {
                m.elements_[j][i] = elements[i][j];
            }
        }
        return m;
    }

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
        return elements_[j][i];
    }

    /**
    Set an element.

    Params:
        value = element value.
        i = row index.
        j = column index.
    Returns:
        assigned element value.
    */
    ref const(E) opIndexAssign()(auto ref const(E) value, size_t i, size_t j) return scope
    in (i < ROWS)
    in (j < COLS)
    {
        return elements_[j][i] = value;
    }

    /**
    operation and assign an element.

    Params:
        op = operator.
        value = element value.
        i = row index.
        j = column index.
    Returns:
        assigned element value.
    */
    ref const(E) opIndexOpAssign(string op)(auto ref const(E) value, size_t i, size_t j) return scope
    in (i < ROWS)
    in (j < COLS)
    {
        return mixin("elements_[j][i] " ~ op ~ "= value");
    }

    /**
    Operation and assign other vector.

    Params:
        value = other vetor value.
    Returns:
        this vector.
    */
    ref typeof(this) opOpAssign(string op)(auto ref const(typeof(this)) value) return scope
    {
        foreach (j, ref column; elements_)
        {
            foreach (i, ref v; column)
            {
                mixin("v " ~ op ~ "= value[i, j];");
            }
        }
        return this;
    }

    /**
    Matrix multiplication.

    Params:
        lhs = left hand side matrix.
        rhs = right hand side matrix.
    Returns:
        calculated this matrix.
    */
    ref typeof(this) mul(size_t N, E1, E2)(
            auto ref const(Matrix!(ROWS, N, E1)) lhs,
            auto ref const(Matrix!(N, COLS, E2)) rhs) return scope
    {
        foreach (j, ref column; elements_)
        {
            foreach (i, ref v; column)
            {
                v = cast(E) 0;
                foreach (k; 0 .. N)
                {
                    v += lhs[i, k] * rhs[k, j];
                }
            }
        }
        return this;
    }

    /**
    Fill elements.

    Params:
        value = filler value.
    */
    ref typeof(this) fill()(auto ref const(E) value) return scope
    {
        foreach (ref row; elements_)
        {
            row[] = value;
        }
        return this;
    }

private:
    E[ROWS][COLS] elements_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable m = Matrix!(2, 3).fromRows([
        [1, 2, 3],
        [4, 5, 6],
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

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto m = Matrix!(2, 2).fromRows([
        [1, 2],
        [3, 4]
    ]);
    m[0, 0] = 3.0f;
    m[0, 1] = 4.0f;
    m[1, 0] = 5.0f;
    m[1, 1] = 6.0f;

    assert(m[0, 0].isClose(3));
    assert(m[0, 1].isClose(4));
    assert(m[1, 0].isClose(5));
    assert(m[1, 1].isClose(6));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto m = Matrix!(2, 2).fromRows([
        [1, 2],
        [3, 4]
    ]);
    m[0, 0] += 1.0f;
    m[0, 1] += 1.0f;
    m[1, 0] += 1.0f;
    m[1, 1] += 1.0f;

    assert(m[0, 0].isClose(2));
    assert(m[0, 1].isClose(3));
    assert(m[1, 0].isClose(4));
    assert(m[1, 1].isClose(5));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto m = Matrix!(2, 2).fromRows([
        [1, 2],
        [3, 4]
    ]);
    immutable t = Matrix!(2, 2).fromRows([
        [3, 4],
        [5, 6]
    ]);

    m += t;

    assert(m[0, 0].isClose(4));
    assert(m[0, 1].isClose(6));
    assert(m[1, 0].isClose(8));
    assert(m[1, 1].isClose(10));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto result = Matrix!(2, 2)();
    immutable lhs = Matrix!(2, 3).fromRows([
        [3, 4, 5],
        [6, 7, 8],
    ]);
    immutable rhs = Matrix!(3, 2).fromRows([
        [3, 4],
        [6, 7],
        [8, 9],
    ]);

    result.mul(lhs, rhs);

    assert(result[0, 0].isClose(3 * 3 + 4 * 6 + 5 * 8));
    assert(result[0, 1].isClose(3 * 4 + 4 * 7 + 5 * 9));
    assert(result[1, 0].isClose(6 * 3 + 7 * 6 + 8 * 8));
    assert(result[1, 1].isClose(6 * 4 + 7 * 7 + 8 * 9));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto m = Matrix!(2, 2)();
    m.fill(1.0);

    assert(m[0, 0].isClose(1.0));
    assert(m[0, 1].isClose(1.0));
    assert(m[1, 0].isClose(1.0));
    assert(m[1, 1].isClose(1.0));
}

