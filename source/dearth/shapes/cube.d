/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : map;
import std.array : array;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.point : Point;
import dearth.shapes.utils :
   PlanePoints,
   PlanePointPaths; 

/**
Params:
    T = vertex type.
    Dg = vertex generator delegate type.
    splitH = horizontal polygon split count.
    splitV = vertical polygon split count.
    splitD = depth polygon split count.
    dg = vertex generator delegate.
Returns:
    Cube shape object.
*/
VertexArrayObject!T createCube(T, Dg)(size_t splitH, size_t splitV, size_t splitD, scope Dg dg)
in (splitH > 0)
in (splitV > 0)
in (splitD > 0)
{
    static assert(isVertexStruct!T);

    auto vao = createVAO!T();
    return vao;
}

private:

struct CubeSidePoints
{
@nogc nothrow pure @safe:

    this(size_t splitH, size_t splitV, size_t splitD) scope
    {
        this.splitH_ = splitH;
        this.splitV_ = splitV;
        this.splitD_ = splitD;
        this.points_ = PlanePoints(
            (splitH + 1) * 2 + (splitD - 1) * 2,
            splitV + 1);
    }

    @property Point front() const scope
    in (!empty)
    {
        immutable p = points_.front;

        if (p.x < frontEdgeIndex)
        {
            return p;
        }
        else if (p.x < rightEdgeIndex)
        {
            return Point(splitH_, p.y, p.x - frontEdgeIndex);
        }
        else if (p.x < backEdgeIndex)
        {
            return Point(splitH_ - (p.x - rightEdgeIndex), p.y, splitD_);
        }

        return Point(0, p.y, splitD_ - (p.x - backEdgeIndex));
    }

    @property bool empty() const scope
    {
        return points_.empty;
    }

    void popFront() scope
    in (!empty)
    {
        points_.popFront();
    }

private:
    size_t splitH_;
    size_t splitV_;
    size_t splitD_;
    PlanePoints points_;

    @property const scope
    {
        size_t frontEdgeIndex() { return splitH_; }
        size_t rightEdgeIndex() { return splitH_ + splitD_; }
        size_t backEdgeIndex() { return (splitH_ * 2) + splitD_; }
    }
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(CubeSidePoints(1, 1, 1).equal([
        Point(0, 0, 0), Point(1, 0, 0), Point(1, 0, 1), Point(0, 0, 1),
        Point(0, 1, 0), Point(1, 1, 0), Point(1, 1, 1), Point(0, 1, 1),
    ]));

    assert(CubeSidePoints(2, 1, 1).equal([
        Point(0, 0, 0), Point(1, 0, 0), Point(2, 0, 0), Point(2, 0, 1), Point(1, 0, 1), Point(0, 0, 1),
        Point(0, 1, 0), Point(1, 1, 0), Point(2, 1, 0), Point(2, 1, 1), Point(1, 1, 1), Point(0, 1, 1),
    ]));

    assert(CubeSidePoints(1, 2, 1).equal([
        Point(0, 0, 0), Point(1, 0, 0), Point(1, 0, 1), Point(0, 0, 1),
        Point(0, 1, 0), Point(1, 1, 0), Point(1, 1, 1), Point(0, 1, 1),
        Point(0, 2, 0), Point(1, 2, 0), Point(1, 2, 1), Point(0, 2, 1),
    ]));

    assert(CubeSidePoints(1, 1, 2).equal([
        Point(0, 0, 0), Point(1, 0, 0), Point(1, 0, 1), Point(1, 0, 2), Point(0, 0, 2), Point(0, 0, 1),
        Point(0, 1, 0), Point(1, 1, 0), Point(1, 1, 1), Point(1, 1, 2), Point(0, 1, 2), Point(0, 1, 1),
    ]));

    assert(CubeSidePoints(2, 2, 2).equal([
        Point(0, 0, 0), Point(1, 0, 0),
        Point(2, 0, 0), Point(2, 0, 1),
        Point(2, 0, 2), Point(1, 0, 2),
        Point(0, 0, 2), Point(0, 0, 1),

        Point(0, 1, 0), Point(1, 1, 0),
        Point(2, 1, 0), Point(2, 1, 1),
        Point(2, 1, 2), Point(1, 1, 2),
        Point(0, 1, 2), Point(0, 1, 1),

        Point(0, 2, 0), Point(1, 2, 0),
        Point(2, 2, 0), Point(2, 2, 1),
        Point(2, 2, 2), Point(1, 2, 2),
        Point(0, 2, 2), Point(0, 2, 1),
    ]));
}

struct CubeSideIndices
{
@nogc nothrow pure @safe:

    this(size_t splitH, size_t splitV, size_t splitD) scope
    {
        this.sidePlaneWidth_ = splitH * 2 + splitD * 2;
        this.paths_ = PlanePointPaths(sidePlaneWidth_, splitV);
    }

    @property ushort front() const scope
    in (!empty)
    {
        immutable p = paths_.front;
        if (p.x == sidePlaneWidth_)
        {
            return cast(ushort)(p.y * sidePlaneWidth_);
        }

        return cast(ushort)(p.y * sidePlaneWidth_ + p.x);
    }

    @property bool empty() const scope
    {
        return paths_.empty;
    }

    void popFront() scope
    in (!empty)
    {
        paths_.popFront();
    }

private:
    size_t sidePlaneWidth_;
    PlanePointPaths paths_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(CubeSideIndices(1, 1, 1).equal([
       0, 1, 4, 1, 5, 4,
       1, 2, 5, 2, 6, 5,
       2, 3, 6, 3, 7, 6,
       3, 0, 7, 0, 4, 7,
    ]));

    assert(CubeSideIndices(2, 1, 1).equal([
       0, 1,  6, 1,  7,  6,
       1, 2,  7, 2,  8,  7,
       2, 3,  8, 3,  9,  8,
       3, 4,  9, 4, 10,  9,
       4, 5, 10, 5, 11, 10,
       5, 0, 11, 0,  6, 11,
    ]));

    assert(CubeSideIndices(1, 1, 2).equal([
       0, 1,  6, 1,  7,  6,
       1, 2,  7, 2,  8,  7,
       2, 3,  8, 3,  9,  8,
       3, 4,  9, 4, 10,  9,
       4, 5, 10, 5, 11, 10,
       5, 0, 11, 0,  6, 11,
    ]));

    assert(CubeSideIndices(1, 2, 1).equal([
       0, 1, 4, 1, 5, 4,
       1, 2, 5, 2, 6, 5,
       2, 3, 6, 3, 7, 6,
       3, 0, 7, 0, 4, 7,

       4, 5,  8, 5,  9,  8,
       5, 6,  9, 6, 10,  9,
       6, 7, 10, 7, 11, 10,
       7, 4, 11, 4,  8, 11,
    ]));
}

