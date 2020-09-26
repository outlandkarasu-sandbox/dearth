/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : joiner, map;
import std.range : array, iota;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

/**
Cube vertex parameter.
*/
struct CubeVertex
{
    float x;
    float y;
    float z;
    size_t h;
    size_t v;
    size_t d;
}

/**
Single plane vertices range.
*/
private struct SinglePlaneVerticesRange
{
    @property const @nogc nothrow pure @safe scope
    {
        CubeVertex front()
        in (!empty)
        {
            return CubeVertex(
                cast(float)((currentH_ * width_) / splitH_),
                cast(float)((currentV_ * height_) / splitV_),
                0.0,
                currentH_,
                currentV_,
                0);
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
    real width_ = 1.0;
    real height_ = 1.0;
}

///
@safe unittest
{
    import std.math : isClose;
    import std.conv : to;

    void assertVertex(
        scope ref const(SinglePlaneVerticesRange) r,
        float x, float y, float z, size_t h, size_t v, size_t d)
    {
        assert(!r.empty);
        assert(r.front.x.isClose(x));
        assert(r.front.y.isClose(y));
        assert(r.front.z.isClose(z));
        assert(r.front.h == h);
        assert(r.front.v == v);
        assert(r.front.d == d);
    }

    auto range = SinglePlaneVerticesRange(2, 4);
    assertVertex(range, 0.0f, 0.0f, 0.0f, 0, 0, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.0f, 0.0f, 1, 0, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.0f, 0.0f, 2, 0, 0);

    range.popFront();
    assertVertex(range, 0.0f, 0.25f, 0.0f, 0, 1, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.25f, 0.0f, 1, 1, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.25f, 0.0f, 2, 1, 0);

    range.popFront();
    assertVertex(range, 0.0f, 0.5f, 0.0f, 0, 2, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.5f, 0.0f, 1, 2, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.5f, 0.0f, 2, 2, 0);

    range.popFront();
    assertVertex(range, 0.0f, 0.75f, 0.0f, 0, 3, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.75f, 0.0f, 1, 3, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.75f, 0.0f, 2, 3, 0);

    range.popFront();
    assertVertex(range, 0.0f, 1.0f, 0.0f, 0, 4, 0);
    range.popFront();
    assertVertex(range, 0.5f, 1.0f, 0.0f, 1, 4, 0);
    range.popFront();
    assertVertex(range, 1.0f, 1.0f, 0.0f, 2, 4, 0);

    range.popFront();
    assert(range.empty);
}

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
VertexArrayObject!T createCube(T, Dg)(
    size_t splitH,
    size_t splitV,
    size_t splitD,
    scope Dg dg)
in (splitH > 0)
in (splitV > 0)
{
    static assert(isVertexStruct!T);

    scope immutable(T)[] vertices = [];
    scope immutable(ushort)[] vertices = [];

    auto vao = createVAO!T();
    vao.loadVertices(vertices);
    vao.loadIndices(indices);
    return vao;
}

