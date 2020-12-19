/**
Shape utilities.
*/
module dearth.shapes.utils;

struct Point
{
    size_t x;
    size_t y;
    size_t z;
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

