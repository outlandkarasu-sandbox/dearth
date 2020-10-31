/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : map;
import std.array : array;
import std.range : chain;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.utils : PlaneVertices, PlaneIndices;

version(unittest)
{
    import std.math : isClose;
    import dearth.shapes.utils : assertVertex;

    void assertCubeVertex(R)(
        scope ref R r,
        real x,
        real y,
        real z,
        size_t h,
        size_t v,
        size_t d)
        @nogc nothrow pure @safe
    {
        assertVertex(r, h, v, d);
        assert(r.front.x.isClose(x));
        assert(r.front.y.isClose(y));
        assert(r.front.z.isClose(z));
    }
}

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

    scope vertices = createVerticesRange(
        splitH, splitV, splitD).map!dg.array;
    scope indices = PlaneIndices(splitH, splitV)
        .map!(i => cast(ushort) i).array;

    auto vao = createVAO!T();
    vao.loadVertices(vertices);
    vao.loadIndices(indices);
    return vao;
}

private:

struct SkipRange(R, alias P)
{
    @disable this();

    this()(return auto scope ref R range, size_t skipTarget) @nogc nothrow pure @safe scope
    {
        this.range_ = range;
        this.skipTarget_ = skipTarget;
        skip();
    }

    @property const @nogc nothrow pure @safe scope
    {
        auto front()
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
    size_t skipTarget_;

    void skip() @nogc nothrow pure @safe scope
    {
        while (!range_.empty && P(range_.front, skipTarget_))
        {
            range_.popFront();
        }
    }
}

auto skipH(R)(return auto scope ref R r, size_t skipH)
{
    return SkipRange!(R, (v, target) => v.h == target)(r, skipH);
}

///
@safe unittest
{
    auto range = PlaneVertices(1, 1).skipH(0);
    assertVertex(range, 1, 0);
    range.popFront();
    assertVertex(range, 1, 1);
    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = PlaneVertices(2, 4).skipH(2);
    assertVertex(range, 0, 0);
    range.popFront();
    assertVertex(range, 1, 0);

    range.popFront();
    assertVertex(range, 0, 1);
    range.popFront();
    assertVertex(range, 1, 1);

    range.popFront();
    assertVertex(range, 0, 2);
    range.popFront();
    assertVertex(range, 1, 2);

    range.popFront();
    assertVertex(range, 0, 3);
    range.popFront();
    assertVertex(range, 1, 3);

    range.popFront();
    assertVertex(range, 0, 4);
    range.popFront();
    assertVertex(range, 1, 4);

    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = PlaneVertices(2, 4).skipH(0).skipH(2);
    assertVertex(range, 1, 0);

    range.popFront();
    assertVertex(range, 1, 1);

    range.popFront();
    assertVertex(range, 1, 2);

    range.popFront();
    assertVertex(range, 1, 3);

    range.popFront();
    assertVertex(range, 1, 4);

    range.popFront();
    assert(range.empty);
}

auto skipV(R)(return auto scope ref R r, size_t skipV)
{
    return SkipRange!(R, (v, target) => v.v == target)(r, skipV);
}

///
@safe unittest
{
    auto range = PlaneVertices(1, 1).skipV(0);
    assertVertex(range, 0, 1);
    range.popFront();
    assertVertex(range, 1, 1);
    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = PlaneVertices(2, 4).skipV(0).skipV(4);
    assertVertex(range, 0, 1);
    range.popFront();
    assertVertex(range, 1, 1);
    range.popFront();
    assertVertex(range, 2, 1);

    range.popFront();
    assertVertex(range, 0, 2);
    range.popFront();
    assertVertex(range, 1, 2);
    range.popFront();
    assertVertex(range, 2, 2);

    range.popFront();
    assertVertex(range, 0, 3);
    range.popFront();
    assertVertex(range, 1, 3);
    range.popFront();
    assertVertex(range, 2, 3);

    range.popFront();
    assert(range.empty);
}

auto createVerticesRange(size_t splitH, size_t splitV, size_t splitD) nothrow pure @safe
{
    auto frontPlane = PlaneVertices(splitH, splitV)
        .map!((v) => CubeVertex(
            (cast(real) v.h) / splitH,
            (cast(real) v.v) / splitV,
            0.0f,
            v.h,
            v.v,
            0));

    auto leftPlane = PlaneVertices(splitD, splitV)
        .skipH(0)
        .map!((v) => CubeVertex(
            0.0f,
            (cast(real) v.v) / splitV,
            (cast(real) v.h) / splitD,
            0,
            v.v,
            v.h));

    auto rightPlane = PlaneVertices(splitD, splitV)
        .skipH(0)
        .map!((v) => CubeVertex(
            1.0f,
            (cast(real) v.v) / splitV,
            (cast(real) v.h) / splitD,
            splitH,
            v.v,
            v.h));

    auto backPlane = PlaneVertices(splitH, splitV)
        .skipH(0).skipH(splitH)
        .map!((v) => CubeVertex(
            (cast(real) v.h) / splitH,
            (cast(real) v.v) / splitV,
            1.0f,
            v.h,
            v.v,
            splitD));

    auto bottomPlane = PlaneVertices(splitH, splitD)
        .skipH(0).skipH(splitH).skipV(0).skipV(splitV)
        .map!((v) => CubeVertex(
            (cast(real) v.h) / splitH,
            0.0f,
            (cast(real) v.v) / splitD,
            v.h,
            0,
            v.v));

    auto topPlane = PlaneVertices(splitH, splitD)
        .skipH(0).skipH(splitH).skipV(0).skipV(splitV)
        .map!((v) => CubeVertex(
            (cast(real) v.h) / splitH,
            1.0f,
            (cast(real) v.v) / splitD,
            v.h,
            splitV,
            v.v));

    return chain(frontPlane, leftPlane, rightPlane, backPlane, bottomPlane, topPlane);
}

///
@safe unittest
{
    auto range = createVerticesRange(1, 1, 1);

    // front
    assertCubeVertex(range, 0.0f, 0.0f, 0.0f, 0, 0, 0);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.0f, 0.0f, 1, 0, 0);
    range.popFront();
    assertCubeVertex(range, 0.0f, 1.0f, 0.0f, 0, 1, 0);
    range.popFront();
    assertCubeVertex(range, 1.0f, 1.0f, 0.0f, 1, 1, 0);

    // left
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.0f, 1.0f, 0, 0, 1);
    range.popFront();
    assertCubeVertex(range, 0.0f, 1.0f, 1.0f, 0, 1, 1);

    // right
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.0f, 1.0f, 1, 0, 1);
    range.popFront();
    assertCubeVertex(range, 1.0f, 1.0f, 1.0f, 1, 1, 1);

    range.popFront();
    assert(range.empty);
}

///
@safe unittest
{
    auto range = createVerticesRange(2, 2, 2);

    // front
    assertCubeVertex(range, 0.0f, 0.0f, 0.0f, 0, 0, 0);
    range.popFront();
    assertCubeVertex(range, 0.5f, 0.0f, 0.0f, 1, 0, 0);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.0f, 0.0f, 2, 0, 0);
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.5f, 0.0f, 0, 1, 0);
    range.popFront();
    assertCubeVertex(range, 0.5f, 0.5f, 0.0f, 1, 1, 0);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.5f, 0.0f, 2, 1, 0);
    range.popFront();
    assertCubeVertex(range, 0.0f, 1.0f, 0.0f, 0, 2, 0);
    range.popFront();
    assertCubeVertex(range, 0.5f, 1.0f, 0.0f, 1, 2, 0);
    range.popFront();
    assertCubeVertex(range, 1.0f, 1.0f, 0.0f, 2, 2, 0);

    // left
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.0f, 0.5f, 0, 0, 1);
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.0f, 1.0f, 0, 0, 2);
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.5f, 0.5f, 0, 1, 1);
    range.popFront();
    assertCubeVertex(range, 0.0f, 0.5f, 1.0f, 0, 1, 2);
    range.popFront();
    assertCubeVertex(range, 0.0f, 1.0f, 0.5f, 0, 2, 1);
    range.popFront();
    assertCubeVertex(range, 0.0f, 1.0f, 1.0f, 0, 2, 2);

    // right
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.0f, 0.5f, 2, 0, 1);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.0f, 1.0f, 2, 0, 2);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.5f, 0.5f, 2, 1, 1);
    range.popFront();
    assertCubeVertex(range, 1.0f, 0.5f, 1.0f, 2, 1, 2);
    range.popFront();
    assertCubeVertex(range, 1.0f, 1.0f, 0.5f, 2, 2, 1);
    range.popFront();
    assertCubeVertex(range, 1.0f, 1.0f, 1.0f, 2, 2, 2);

    // back
    range.popFront();
    assertCubeVertex(range, 0.5f, 0.0f, 1.0f, 1, 0, 2);
    range.popFront();
    assertCubeVertex(range, 0.5f, 0.5f, 1.0f, 1, 1, 2);
    range.popFront();
    assertCubeVertex(range, 0.5f, 1.0f, 1.0f, 1, 2, 2);

    // bottom
    range.popFront();
    assertCubeVertex(range, 0.5f, 0.0f, 0.5f, 1, 0, 1);

    // top
    range.popFront();
    assertCubeVertex(range, 0.5f, 1.0f, 0.5f, 1, 2, 1);

    range.popFront();
    assert(range.empty);
}

