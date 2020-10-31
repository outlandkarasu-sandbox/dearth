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

import dearth.shapes.utils : PlaneIndices;

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

