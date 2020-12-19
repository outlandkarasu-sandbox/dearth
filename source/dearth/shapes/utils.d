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

    Point front() const scope
    in (!empty)
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
    uint current_;
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
}

struct PlanePoints
{
@nogc nothrow pure @safe:

    this(size_t width, size_t height) scope
    {
        this.width_ = width;
        this.height_ = height;
    }

    Point front() const scope
    in (!empty)
    {
        return Point(x_, y_);
    }

    void popFront() scope
    in (!empty)
    {
        ++x_;

        if (x_ >= width_)
        {
            x_ = 0;
            ++y_;
        }
    }

    bool empty() const scope
    {
        return y_ == height_;
    }

private:
    size_t width_;
    size_t height_;
    size_t x_;
    size_t y_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(PlanePoints().empty);
    assert(PlanePoints(1, 1).equal([Point(0, 0)]));
    assert(PlanePoints(2, 1).equal([Point(0, 0), Point(1, 0)]));
    assert(PlanePoints(1, 2).equal([Point(0, 0), Point(0, 1)]));
    assert(PlanePoints(2, 2).equal([
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 1),
    ]));
}

