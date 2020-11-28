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
    return PlaneVertices(splitH, splitV)
        .map!((v) => CubeVertex(
            (v.h == splitH) ? 1.0f : (1.0f * v.h / splitH),
            (v.v == splitV) ? 1.0f : (1.0f * v.v / splitV),
            0.0f,
            v.h,
            v.v,
            0));
}

auto createIndicesRange(size_t splitH, size_t splitV, size_t splitD) @nogc nothrow pure @safe
{
    return PlaneIndices(splitH, splitV).map!(i => cast(ushort) i.i);
}

