/**
Plane shape.
*/
module dearth.shapes.plane;

import std.algorithm : joiner, map;
import std.range : array, iota;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.utils : PlaneTriangleIndices;

/**
Plane vertex parameter.
*/
struct PlaneVertex
{
    float x;
    float y;
    float z;
    size_t h;
    size_t v;
}

/**
Params:
    T = vertex type.
    Dg = vertex generator delegate.
    splitH = horizontal polygon split count.
    splitV = vertical polygon split count.
Returns:
    Plane shape object.
*/
VertexArrayObject!T createPlane(T, Dg)(size_t splitH, size_t splitV, scope Dg dg)
in (splitH > 0)
in (splitV > 0)
{
    static assert(isVertexStruct!T);

    scope vertices = iota(splitV + 1)
        .map!(v => iota(splitH + 1)
            .map!(h => dg(PlaneVertex(
                h == splitH ? 1.0 : (1.0 * h / splitH),
                v == splitV ? 1.0 : (1.0 * v / splitV),
                0.0,
                h, v)))
        )
        .joiner
        .array;
    scope indices = PlaneIndices(splitH, splitV).map!(i => cast(ushort) i).array;

    auto vao = createVAO!T();
    vao.loadVertices(vertices);
    vao.loadIndices(indices);
    return vao;
}

private:

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

    size_t front() const scope
    {
        return current_.front;
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
    import std.algorithm : equal;

    auto indices11 = PlaneIndices(1, 1);
    immutable size_t[6] expected11 = [0, 1, 3, 3, 2, 0];
    assert(indices11.equal(expected11[]));

    auto indices21 = PlaneIndices(2, 1);
    immutable size_t[12] expected21 = [
        0, 1, 4, 4, 3, 0,
        1, 2, 5, 5, 4, 1];
    assert(indices21.equal(expected21[]));

    auto indices12 = PlaneIndices(1, 2);
    immutable size_t[12] expected12 = [
        0, 1, 3, 3, 2, 0,
        2, 3, 5, 5, 4, 2];
    assert(indices12.equal(expected12[]));

    auto indices22 = PlaneIndices(2, 2);
    immutable size_t[24] expected22 = [
        0, 1, 4, 4, 3, 0,
        1, 2, 5, 5, 4, 1,
        3, 4, 7, 7, 6, 3,
        4, 5, 8, 8, 7, 4,
    ];
    assert(indices22.equal(expected22[]));
}

