/**
Shape utilities.
*/
module dearth.shapes.utils;

/**
Plane indices range.
*/
struct PlaneTriangleIndices
{
@nogc nothrow pure @safe:

    this(size_t offsetTop, size_t offsetBottom) scope
    {
        this.indices_ = [
            offsetTop + 0, offsetTop + 1, offsetBottom + 1,
            offsetBottom + 1, offsetBottom + 0, offsetTop + 0];
    }

    size_t front() const scope
    {
        return indices_[i_];
    }

    void popFront() scope
    {
        ++i_;
    }

    bool empty() const scope
    {
        return i_ >= indices_.length;
    }

private:
    size_t[6] indices_;
    size_t i_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    auto indices = PlaneTriangleIndices(0, 2);
    assert(indices.front == 0);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.front == 1);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.front == 3);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.front == 3);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.front == 2);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.front == 0);
    assert(!indices.empty);

    indices.popFront();
    assert(indices.empty);

    auto indices11 = PlaneTriangleIndices(11, 22);
    scope size_t[6] expected11 = [11 + 0, 11 + 1, 22 + 1, 22 + 1, 22 + 0, 11 + 0];
    assert(indices11.equal(expected11[]));
}

