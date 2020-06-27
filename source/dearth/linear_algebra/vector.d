/**
Vector module.
*/
module dearth.linear_algebra.vector;

import std.traits : isNumeric;

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
    ref const(E) opIndex(size_t i) const return scope
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
    ref const(E) opIndexAssign()(auto ref const(E) value, size_t i) return scope
    in (i < D)
    {
        return elements_[i] = value;
    }

    /**
    operation and assign an element.

    Params:
        op = operator.
        value = element value.
        i = index.
    Returns:
        assigned element value.
    */
    ref const(E) opIndexOpAssign(string op)(auto ref const(E) value, size_t i) return scope
    in (i < D)
    {
        return mixin("elements_[i] " ~ op ~ "= value");
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
        foreach (i, ref v; elements_)
        {
            mixin("v " ~ op ~ "= value[i];");
        }
        return this;
    }

    /**
    Returns:
        elements slice.
    */
    const(E)[] opSlice() const return scope
    {
        return elements_[];
    }

    /**
    Fill elements.

    Params:
        value = filler value.
    */
    ref typeof(this) fill()(auto ref const(E) value) return scope
    {
        elements_[] = value;
        return this;
    }

    /**
    Vector pointer.

    Returns:
        vector pointer.
    */
    @property const(E)* ptr() const return scope
    out (r; r != null)
    {
        return &elements_[0];
    }

private:
    E[D] elements_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable v = Vector!3([1, 2, 3]);
    assert(v[0].isClose(1.0));
    assert(v[1].isClose(2.0));
    assert(v[2].isClose(3.0));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto v = Vector!3([1, 2, 3]);
    v[0] = 2.0f;
    v[1] = 3.0f;
    v[2] = 4.0f;

    assert(v[0].isClose(2.0));
    assert(v[1].isClose(3.0));
    assert(v[2].isClose(4.0));

    v[0] += 1.0f;
    v[1] += 1.0f;
    v[2] += 1.0f;

    assert(v[0].isClose(3.0));
    assert(v[1].isClose(4.0));
    assert(v[2].isClose(5.0));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    auto v = Vector!3([1, 2, 3]);
    immutable u = Vector!3([2, 3, 4]);
    v += u;

    assert(v[0].isClose(3.0));
    assert(v[1].isClose(5.0));
    assert(v[2].isClose(7.0));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose, isNaN;

    Vector!3 v;
    assert(v[0].isNaN);
    assert(v[1].isNaN);
    assert(v[2].isNaN);

    immutable u = Vector!3([2, 3, 4]);
    foreach (i, e; u[])
    {
        v[i] = e;
    }

    assert(v[0].isClose(2.0));
    assert(v[1].isClose(3.0));
    assert(v[2].isClose(4.0));
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose, isNaN;

    Vector!3 v;
    v.fill(1.0);
    foreach (e; v[])
    {
        assert(e.isClose(1.0));
    }
}

///
@nogc nothrow pure @safe unittest
{
    import std.math : isClose;

    immutable v = Vector!3([1, 2, 3]);
    assert(isClose(*(v.ptr), 1.0));
}

