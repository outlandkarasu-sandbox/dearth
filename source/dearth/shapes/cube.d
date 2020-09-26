/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : map;
import std.range : chain;

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

    scope immutable(T)[] vertices = [];
    scope immutable(ushort)[] vertices = [];

    auto vao = createVAO!T();
    vao.loadVertices(vertices);
    vao.loadIndices(indices);
    return vao;
}

private:

/**
Plane vertex parameter.
*/
struct PlaneVertex
{
    float x;
    float y;
    size_t h;
    size_t v;
}

version(unittest)
{
    void assertVertex(R)(
        scope ref const(R) r,
        float x, float y, size_t h, size_t v)
        @nogc nothrow pure @safe
    {
        import std.math : isClose;

        assert(!r.empty);
        assert(r.front.x.isClose(x));
        assert(r.front.y.isClose(y));
        assert(r.front.h == h);
        assert(r.front.v == v);
    }
}

/**
Single plane vertices range.
*/
struct SinglePlaneVerticesRange
{
    @property const @nogc nothrow pure @safe scope
    {
        PlaneVertex front()
        in (!empty)
        {
            return PlaneVertex(
                cast(float)((currentH_ * width_) / splitH_),
                cast(float)((currentV_ * height_) / splitV_),
                currentH_,
                currentV_);
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
    auto range = SinglePlaneVerticesRange(1, 1);
    assertVertex(range, 0.0f, 0.0f, 0, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.0f, 1, 0);
    range.popFront();
    assertVertex(range, 0.0f, 1.0f, 0, 1);
    range.popFront();
    assertVertex(range, 1.0f, 1.0f, 1, 1);
    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = SinglePlaneVerticesRange(2, 4);
    assertVertex(range, 0.0f, 0.0f, 0, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.0f, 1, 0);
    range.popFront();
    assertVertex(range, 1.0f, 0.0f, 2, 0);

    range.popFront();
    assertVertex(range, 0.0f, 0.25f, 0, 1);
    range.popFront();
    assertVertex(range, 0.5f, 0.25f, 1, 1);
    range.popFront();
    assertVertex(range, 1.0f, 0.25f, 2, 1);

    range.popFront();
    assertVertex(range, 0.0f, 0.5f, 0, 2);
    range.popFront();
    assertVertex(range, 0.5f, 0.5f, 1, 2);
    range.popFront();
    assertVertex(range, 1.0f, 0.5f, 2, 2);

    range.popFront();
    assertVertex(range, 0.0f, 0.75f, 0, 3);
    range.popFront();
    assertVertex(range, 0.5f, 0.75f, 1, 3);
    range.popFront();
    assertVertex(range, 1.0f, 0.75f, 2, 3);

    range.popFront();
    assertVertex(range, 0.0f, 1.0f, 0, 4);
    range.popFront();
    assertVertex(range, 0.5f, 1.0f, 1, 4);
    range.popFront();
    assertVertex(range, 1.0f, 1.0f, 2, 4);

    range.popFront();
    assert(range.empty);
}

struct SkipHRange(R)
{
    @disable this();

    this()(return auto scope ref R range, size_t skipH) @nogc nothrow pure @safe scope
    {
        this.range_ = range;
        this.skipH_ = skipH;
        skip();
    }

    @property const @nogc nothrow pure @safe scope
    {
        PlaneVertex front()
        in (!empty)
        {
            return range_.front;
        }

        bool empty()
        {
            return range_.empty;
        }
    }

    void popFront() @nogc nothrow pure @safe scope
    in (!empty)
    {
        range_.popFront();
        skip();
    }

private:
    R range_;
    size_t skipH_;

    void skip() @nogc nothrow pure @safe scope
    {
        while (!range_.empty && range_.front.h == skipH_)
        {
            range_.popFront();
        }
    }
}

auto skipH(R)(return auto scope ref R r, size_t skipH)
{
    return SkipHRange!R(r, skipH);
}

///
@safe unittest
{
    auto range = SinglePlaneVerticesRange(1, 1).skipH(0);
    assertVertex(range, 1.0f, 0.0f, 1, 0);
    range.popFront();
    assertVertex(range, 1.0f, 1.0f, 1, 1);
    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = SinglePlaneVerticesRange(2, 4).skipH(2);
    assertVertex(range, 0.0f, 0.0f, 0, 0);
    range.popFront();
    assertVertex(range, 0.5f, 0.0f, 1, 0);

    range.popFront();
    assertVertex(range, 0.0f, 0.25f, 0, 1);
    range.popFront();
    assertVertex(range, 0.5f, 0.25f, 1, 1);

    range.popFront();
    assertVertex(range, 0.0f, 0.5f, 0, 2);
    range.popFront();
    assertVertex(range, 0.5f, 0.5f, 1, 2);

    range.popFront();
    assertVertex(range, 0.0f, 0.75f, 0, 3);
    range.popFront();
    assertVertex(range, 0.5f, 0.75f, 1, 3);

    range.popFront();
    assertVertex(range, 0.0f, 1.0f, 0, 4);
    range.popFront();
    assertVertex(range, 0.5f, 1.0f, 1, 4);

    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = SinglePlaneVerticesRange(2, 4).skipH(0).skipH(2);
    assertVertex(range, 0.5f, 0.0f, 1, 0);

    range.popFront();
    assertVertex(range, 0.5f, 0.25f, 1, 1);

    range.popFront();
    assertVertex(range, 0.5f, 0.5f, 1, 2);

    range.popFront();
    assertVertex(range, 0.5f, 0.75f, 1, 3);

    range.popFront();
    assertVertex(range, 0.5f, 1.0f, 1, 4);

    range.popFront();
    assert(range.empty);
}

auto createVerticesRange(size_t splitH, size_t splitV, size_t splitD) nothrow pure @safe
{
    auto frontPlane = SinglePlaneVerticesRange(splitH, splitV)
        .map!((v) => CubeVertex(v.x, v.y, 0.0f, v.h, v.v, 0));
    auto rightPlane = SinglePlaneVerticesRange(splitD, splitV)
        .map!((v) => CubeVertex(1.0f, v.y, v.x, splitH, v.v, v.h));
    auto leftPlane = SinglePlaneVerticesRange(splitD, splitV)
        .map!((v) => CubeVertex(0.0f, v.y, v.x, 0, v.v, v.h));
    auto backPlane = SinglePlaneVerticesRange(splitH, splitV)
        .map!((v) => CubeVertex(v.x, v.y, 1.0f, v.h, v.v, splitD));
    auto topPlane = SinglePlaneVerticesRange(splitH, splitD)
        .map!((v) => CubeVertex(v.x, 1.0f, v.y, v.h, splitV, v.v));
    auto bottomPlane = SinglePlaneVerticesRange(splitH, splitD)
        .map!((v) => CubeVertex(v.x, 0.0f, v.y, v.h, 0, v.v));
    return chain(frontPlane, rightPlane, leftPlane, backPlane, topPlane, bottomPlane);
}

