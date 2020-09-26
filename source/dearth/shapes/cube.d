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
Params:
    T = vertex type.
    Dg = vertex generator delegate.
    splitH = horizontal polygon split count.
    splitV = vertical polygon split count.
Returns:
    Cube shape object.
*/
VertexArrayObject!T createCube(T, Dg)(size_t splitH, size_t splitV, scope Dg dg)
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

