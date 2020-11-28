/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : filter, map;
import std.array : array;
import std.range : chain;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.utils :
    PlaneVertex,
    PlaneVertices,
    PlaneIndices,
    planeIndicesCount;

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
    scope indices = createIndicesRange(splitH, splitV, splitD).array;

    auto vao = createVAO!T();
    vao.loadVertices(vertices);
    vao.loadIndices(indices);
    return vao;
}

private:

auto createVerticesRange(size_t splitH, size_t splitV, size_t splitD) nothrow pure @safe
{
    immutable frontStart = 0;
    immutable rightStart = frontStart + splitH;
    immutable backStart = rightStart + splitD;
    immutable leftStart = backStart + splitH;

    bool isFront(scope ref const(PlaneVertex) v) @nogc
    {
        return frontStart <= v.h && v.h < rightStart;
    }

    bool isRight(scope ref const(PlaneVertex) v) @nogc
    {
        return rightStart <= v.h && v.h < backStart;
    }

    bool isBack(scope ref const(PlaneVertex) v) @nogc
    {
        return backStart <= v.h && v.h < leftStart;
    }

    size_t generateHPosition(scope ref const(PlaneVertex) v) @nogc
    {
        if (isFront(v)) return v.h;
        else if (isRight(v)) return splitH;
        else if (isBack(v)) return leftStart - v.h;
        else return 0;
    }

    size_t generateDPosition(scope ref const(PlaneVertex) v) @nogc
    {
        if (isFront(v)) return 0;
        else if (isRight(v)) return v.h - rightStart;
        else if (isBack(v)) return splitD;
        else return splitD - (v.h - leftStart);
    }

    float generateXPosition(scope ref const(PlaneVertex) v) @nogc
    {
        immutable h = generateHPosition(v);
        return h == splitH ? 1.0f : (1.0f * h / splitH);
    }

    float generateZPosition(scope ref const(PlaneVertex) v) @nogc
    {
        immutable d = generateDPosition(v);
        return d == splitD ? 1.0f : (1.0f * d / splitD);
    }

    immutable leftEnd = leftStart + splitD;
    return PlaneVertices(splitH * 2 + splitD * 2, splitV)
        .filter!((v) => v.h < leftEnd)
        .map!((v) => CubeVertex(
            generateXPosition(v),
            (v.v == splitV) ? 1.0f : (1.0f * v.v / splitV),
            generateZPosition(v),
            generateHPosition(v),
            v.v,
            generateDPosition(v)));
}

///
pure @safe unittest
{
    immutable vertices = createVerticesRange(1, 1, 1).array;
    assert(vertices.length == 8);

    assertVertex(vertices[0], 0.0f, 0.0f, 0.0f, 0, 0, 0);
    assertVertex(vertices[1], 1.0f, 0.0f, 0.0f, 1, 0, 0);
    assertVertex(vertices[2], 1.0f, 0.0f, 1.0f, 1, 0, 1);
    assertVertex(vertices[3], 0.0f, 0.0f, 1.0f, 0, 0, 1);

    assertVertex(vertices[4], 0.0f, 1.0f, 0.0f, 0, 1, 0);
    assertVertex(vertices[5], 1.0f, 1.0f, 0.0f, 1, 1, 0);
    assertVertex(vertices[6], 1.0f, 1.0f, 1.0f, 1, 1, 1);
    assertVertex(vertices[7], 0.0f, 1.0f, 1.0f, 0, 1, 1);
}

///
pure @safe unittest
{
    immutable vertices = createVerticesRange(2, 2, 2).array;
    assert(vertices.length == 24);

    foreach (i; 0 .. 3)
    {
        immutable offset = i * 8;
        immutable y = (i == 2) ? 1.0f : 1.0f * i / 2;
        assertVertex(vertices[0 + offset], 0.0f, y, 0.0f, 0, i, 0);
        assertVertex(vertices[1 + offset], 0.5f, y, 0.0f, 1, i, 0);
        assertVertex(vertices[2 + offset], 1.0f, y, 0.0f, 2, i, 0);
        assertVertex(vertices[3 + offset], 1.0f, y, 0.5f, 2, i, 1);
        assertVertex(vertices[4 + offset], 1.0f, y, 1.0f, 2, i, 2);
        assertVertex(vertices[5 + offset], 0.5f, y, 1.0f, 1, i, 2);
        assertVertex(vertices[6 + offset], 0.0f, y, 1.0f, 0, i, 2);
        assertVertex(vertices[7 + offset], 0.0f, y, 0.5f, 0, i, 1);
    }
}

auto createIndicesRange(size_t splitH, size_t splitV, size_t splitD) @nogc nothrow pure @safe
{
    return PlaneIndices(splitH * 2 + splitD * 2, splitV).map!(i => cast(ushort) i.i);
}

version(unittest)
{
    import std.math : isClose;

    void assertVertex(
        scope ref const(CubeVertex) vertex,
        float x, float y, float z, size_t h, size_t v, size_t d)
    @nogc nothrow pure @safe
    {
        assert(vertex.x.isClose(x));
        assert(vertex.y.isClose(y));
        assert(vertex.z.isClose(z));
        assert(vertex.h == h);
        assert(vertex.v == v);
        assert(vertex.d == d);
    }
}

