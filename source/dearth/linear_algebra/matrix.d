/**
Matrix module.
*/
module dearth.linear_algebra.matrix;

import std.math : cos, sin;
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
    Returns:
        initialized matrix.
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

    static if(COLS == ROWS)
    {
        /**
        Initialize unit matrix.

        Returns:
            unit matrix;
        */
        static typeof(this) unit()
        {
            auto m = typeof(this)();
            foreach (j; 0 .. COLS)
            {
                foreach (i; 0 .. ROWS)
                {
                    m.elements_[j][i] = cast(E)((i == j) ? 1 : 0);
                }
            }
            return m;
        }

        /**
        Create scale matrix.

        Params:
            factors = scale factors.
        Returns:
            scale matrix.
        */
        static typeof(this) scale(Factors...)(Factors factors)
        {
            static assert(factors.length == COLS - 1);
            auto m = typeof(this)();
            m.fill(cast(E) 0);
            foreach (i, f; factors)
            {
                m[i, i] = cast(E) f;
            }
            m[ROWS - 1, COLS - 1] = cast(E) 1.0;
            return m;
        }

        /**
        Create translate matrix.

        Params:
            factors = translate factors.
        Returns:
            translate matrix.
        */
        static typeof(this) translate(Factors...)(Factors factors)
        {
            static assert(factors.length == COLS - 1);

            auto m = typeof(this).unit();
            foreach (i, f; factors)
            {
                m[i, COLS - 1] = cast(E) f;
            }
            return m;
        }

        /**
        Create rotation X matrix.

        Params:
            theta = rotate theta.
        Returns:
            rotation matrix.
        */
        static typeof(this) rotateX(E theta) if (ROWS == 4 && COLS == 4)
        {
            auto m = typeof(this).unit();
            m[1, 1] = cos(x);
            m[1, 2] = -sin(x);
            m[2, 1] = sin(x);
            m[2, 2] = cos(x);
            return m;
        }

        /**
        Create rotation Y matrix.

        Params:
            theta = rotate theta.
        Returns:
            rotation matrix.
        */
        static typeof(this) rotateY(E theta) if (ROWS == 4 && COLS == 4)
        {
            auto m = typeof(this).unit();
            m[0, 0] = cos(x);
            m[0, 2] = sin(x);
            m[2, 0] = -sin(x);
            m[2, 2] = cos(x);
            return m;
        }

        /**
        Create rotation Z matrix.

        Params:
            theta = rotate theta.
        Returns:
            rotation matrix.
        */
        static typeof(this) rotateZ(E theta) if (ROWS == 4 && COLS == 4)
        {
            auto m = typeof(this).unit();
            m[0, 0] = cos(x);
            m[0, 1] = -sin(x);
            m[1, 0] = sin(x);
            m[1, 1] = cos(x);
            return m;
        }
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
        foreach (ref column; elements_)
        {
            column[] = value;
        }
        return this;
    }

    /**
    Matrix pointer.

    Returns:
        matrix pointer.
    */
    @property const(E)* ptr() const return scope
    out (r; r != null)
    {
        return &elements_[0][0];
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

    immutable m = Matrix!(3, 3).unit;
    assert(m.rows == 3);
    assert(m.columns == 3);

    assert(m[0, 0].isClose(1));
    assert(m[0, 1].isClose(0));
    assert(m[0, 2].isClose(0));
    assert(m[1, 0].isClose(0));
    assert(m[1, 1].isClose(1));
    assert(m[1, 2].isClose(0));
    assert(m[2, 0].isClose(0));
    assert(m[2, 1].isClose(0));
    assert(m[2, 2].isClose(1));
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

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable m = Matrix!(2, 2)([[1, 2], [3, 4]]);
    assert(isClose(*(m.ptr), 1.0));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable m = Matrix!(4, 4).scale(2.0, 3.0, 4.0);
    assert(m[0, 0].isClose(2.0));
    assert(m[1, 1].isClose(3.0));
    assert(m[2, 2].isClose(4.0));
    assert(m[3, 3].isClose(1.0));

    foreach (i; 0 .. 4)
    {
        foreach (j; 0 .. 4)
        {
            if (i != j)
            {
                assert(m[i, j].isClose(0.0));
            }
        }
    }
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable m = Matrix!(4, 4).translate(2.0, 3.0, 4.0);
    assert(m[0, 3].isClose(2.0));
    assert(m[1, 3].isClose(3.0));
    assert(m[2, 3].isClose(4.0));
    assert(m[3, 3].isClose(1.0));

    foreach (i; 0 .. 4)
    {
        foreach (j; 0 .. 3)
        {
            assert(m[i, j].isClose((i != j) ? 0.0 : 1.0));
        }
    }
}

