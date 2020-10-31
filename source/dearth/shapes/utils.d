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

/**
Plane index and division info.
*/
struct PlaneIndex
{
    size_t i;
    size_t h;
    size_t v;
}

/**
Plane indices range.
*/
struct PlaneIndices
{
@nogc nothrow pure @safe:

    this(size_t splitH, size_t splitV) scope
    in (splitH > 0)
    in (splitV > 0)
    {
        this.splitH_ = splitH;
        this.splitV_ = splitV;
        this.current_ = PlaneTriangleIndices(0, indicesH);
    }

    PlaneIndex front() const scope
    {
        return PlaneIndex(current_.front, currentH_, currentV_);
    }

    void popFront() scope
    {
        current_.popFront();
        if (!current_.empty)
        {
            return;
        }

        ++currentH_;
        if (currentH_ >= splitH_ && currentV_ < splitV_)
        {
            currentH_ = 0;
            ++currentV_;
        }

        current_ = PlaneTriangleIndices(offsetTop, offsetBottom);
    }

    bool empty() const scope
    {
        return currentV_ >= splitV_;
    }

private:

    size_t indicesH() const scope
    {
        return splitH_ + 1;
    }

    size_t offsetTop() const scope
    {
        return (currentV_ * indicesH) + currentH_;
    }

    size_t offsetBottom() const scope
    {
        return offsetTop + indicesH;
    }

    PlaneTriangleIndices current_;
    size_t currentH_;
    size_t splitH_;
    size_t currentV_;
    size_t splitV_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal, map;

    auto indices11 = PlaneIndices(1, 1);
    immutable size_t[6] expected11 = [0, 1, 3, 3, 2, 0];
    assert(indices11.map!"a.i".equal(expected11[]));

    auto indices21 = PlaneIndices(2, 1);
    immutable size_t[12] expected21 = [
        0, 1, 4, 4, 3, 0,
        1, 2, 5, 5, 4, 1];
    assert(indices21.map!"a.i".equal(expected21[]));

    auto indices12 = PlaneIndices(1, 2);
    immutable size_t[12] expected12 = [
        0, 1, 3, 3, 2, 0,
        2, 3, 5, 5, 4, 2];
    assert(indices12.map!"a.i".equal(expected12[]));

    auto indices22 = PlaneIndices(2, 2);
    immutable size_t[24] expected22 = [
        0, 1, 4, 4, 3, 0,
        1, 2, 5, 5, 4, 1,
        3, 4, 7, 7, 6, 3,
        4, 5, 8, 8, 7, 4,
    ];
    assert(indices22.map!"a.i".equal(expected22[]));
}

/**
Calculate triangle indices count.

Params:
    h = horizontal division.
    v = vertical division.
Returns:
    indices count.
*/
size_t planeIndicesCount(size_t h, size_t v) @nogc nothrow pure @safe
{
    return h * v * 6;
}

///
@nogc nothrow pure @safe unittest
{
    void assertCount(size_t h, size_t v)
    {
        import std.algorithm : count;
        assert(planeIndicesCount(h, v) == PlaneIndices(h, v).count);
    }

    assertCount(1, 1);
    assertCount(2, 1);
    assertCount(1, 2);
    assertCount(2, 2);
    assertCount(10, 1);
    assertCount(1, 10);
    assertCount(10, 10);
}

/**
Plane vertex.
*/
struct PlaneVertex
{
    size_t h;
    size_t v;
}

version(unittest)
{
    void assertVertex(R)(scope ref R r, size_t h, size_t v)
        @nogc nothrow pure @safe
    {
        assert(!r.empty);
        assert(r.front.h == h);
        assert(r.front.v == v);
    }

    void assertVertex(R)(scope ref R r, size_t h, size_t v, size_t d)
        @nogc nothrow pure @safe
    {
        assert(!r.empty);
        assert(r.front.h == h);
        assert(r.front.v == v);
        assert(r.front.d == d);
    }
}

/**
Plane vertices range.
*/
struct PlaneVertices
{
    @property const @nogc nothrow pure @safe scope
    {
        PlaneVertex front()
        in (!empty)
        {
            return PlaneVertex(currentH_, currentV_);
        }

        bool empty()
        {
            return currentV_ > splitV_;
        }
    }

    void popFront() @nogc nothrow pure @safe scope
    in (!empty)
    {
        ++currentH_;
        if (currentH_ > splitH_)
        {
            ++currentV_;
            currentH_ = 0;
        }
    }

private:
    size_t splitH_;
    size_t splitV_;
    size_t currentH_;
    size_t currentV_;
}

///
@safe unittest
{
    auto range = PlaneVertices(1, 1);
    assertVertex(range, 0, 0);
    range.popFront();
    assertVertex(range, 1, 0);
    range.popFront();
    assertVertex(range, 0, 1);
    range.popFront();
    assertVertex(range, 1, 1);
    range.popFront();
    assert(range.empty);
}

