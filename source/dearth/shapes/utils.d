/**
Shape utilities.
*/
module dearth.shapes.utils;

struct Point
{
    size_t x;
    size_t y;
}

struct PlaneTrianglePoints
{
@nogc nothrow pure @safe:

    this(size_t offsetX, size_t offsetY) scope
    {
        this.offsetX_ = offsetX;
        this.offsetY_ = offsetY;
    }

    Point front() const scope
    in (!empty)
    {
        immutable p = frontWithoutOffset;
        return Point(p.x + offsetX_, p.y + offsetY_);
    }

    void popFront() scope
    in (!empty)
    {
        ++current_;
    }

    bool empty() const scope
    {
        return current_ >= LENGTH;
    }

private:
    enum LENGTH = 6;
    size_t offsetX_;
    size_t offsetY_;
    uint current_;

    Point frontWithoutOffset() const scope
    {
        switch (current_)
        {
            default: case 0: return Point(0, 0);
            case 1: return Point(1, 0);
            case 2: return Point(0, 1);
            case 3: return Point(1, 0);
            case 4: return Point(1, 1);
            case 5: return Point(0, 1);
        }
    }
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(PlaneTrianglePoints().equal([
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 0),
        Point(1, 1),
        Point(0, 1),
    ]));

    assert(PlaneTrianglePoints(3, 0).equal([
        Point(3, 0),
        Point(4, 0),
        Point(3, 1),
        Point(4, 0),
        Point(4, 1),
        Point(3, 1),
    ]));

    assert(PlaneTrianglePoints(0, 3).equal([
        Point(0, 3),
        Point(1, 3),
        Point(0, 4),
        Point(1, 3),
        Point(1, 4),
        Point(0, 4),
    ]));

    assert(PlaneTrianglePoints(3, 3).equal([
        Point(3, 3),
        Point(4, 3),
        Point(3, 4),
        Point(4, 3),
        Point(4, 4),
        Point(3, 4),
    ]));
}


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

