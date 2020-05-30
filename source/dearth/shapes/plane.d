/**
Plane shape.
*/
module dearth.shapes.plane;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

private struct PlaneTriangleIndices
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
    scope size_t[6] expected = [0, 1, 3, 3, 2, 0];
    assert(indices.equal(expected[]));

    auto indices11 = PlaneTriangleIndices(11, 22);
    scope size_t[6] expected11 = [11 + 0, 11 + 1, 22 + 1, 22 + 1, 22 + 0, 11 + 0];
    assert(indices11.equal(expected11[]));
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
{
    static assert(isVertexStruct!T);
    auto vao = createVAO!Vertex();
    vao.loadVertices(vertices);
    vao.loadIndices([0, 1, 2, 2, 3, 0]);
    return vao;
}

