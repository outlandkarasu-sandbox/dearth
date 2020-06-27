/**
Vector module.
*/
module dearth.linear_algebra.vector;

import std.traits : isNumeric;

@safe @nogc:

/**
Vector structure.

Params:
    D = dimensions.
    E = element type.
*/
struct Vector(size_t D, E = float)
{
    static assert(D > 0);
    static assert(isNumeric!E);

    /**
    Get an element.

    Params:
        i = index.
    Returns:
        element value.
    */
    ref const(E) opIndex(size_t i) const nothrow pure return scope
    in (i < D)
    {
        return elements_[i];
    }

    /**
    Set an element.

    Params:
        value = element value.
        i = index.
    Returns:
        assigned element value.
    */
    ref const(E) opIndexAssign()(auto ref const(E) value, size_t i) nothrow pure return scope
    in (i < D)
    {
        return elements_[i] = value;
    }

private:
    E[D] elements_;
}

///
nothrow pure unittest
{
    import std.math : isClose;

    immutable v = Vector!3([1, 2, 3]);
    assert(v[0].isClose(1.0));
    assert(v[1].isClose(2.0));
    assert(v[2].isClose(3.0));
}

///
nothrow pure unittest
{
    import std.math : isClose;

    auto v = Vector!3([1, 2, 3]);
    v[0] = 2.0f;
    v[1] = 3.0f;
    v[2] = 4.0f;

    assert(v[0].isClose(2.0));
    assert(v[1].isClose(3.0));
    assert(v[2].isClose(4.0));
}

