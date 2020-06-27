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
    E opIndex(size_t i) const nothrow pure scope
    in (i < D)
    {
        return elements_[i];
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

